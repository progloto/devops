#!/bin/bash

# Servers list file
SERVERS_FILE=".servers"

# Registry credentials file
REGISTRY_FILE=".registry"

# Compose file path (adjust if needed)
COMPOSE_FILE="./docker-compose.yaml"

# Function to read registry credentials from file
read_registry_credentials() {
  if [[ -f "$REGISTRY_FILE" ]]; then
    read -r REGISTRY_USER REGISTRY_PASSWORD < "$REGISTRY_FILE"
  else
    echo "Error: Registry credentials file '$REGISTRY_FILE' not found."
    exit 1
  fi
}

# Function to update container on a single server using docker compose
update_container() {
  local server_info=$1
  local server_name=$(echo "$server_info" | awk '{print $1}')
  local ssh_host=$(echo "$server_info" | awk '{print $2}')
  local ssh_port=$(echo "$server_info" | awk '{print $3}')
  #local image_name=$(docker -H "ssh://$ssh_host:$ssh_port" compose --file "$COMPOSE_FILE" images | awk 'NR==2 {print $1}')
  #local image_name=$(docker compose config --images | awk 'NR==2 {print $1}')
  local image_name="online"

  echo "Updating container on $server_name..."

  # Read registry credentials
  read_registry_credentials

  # Login to the private registry
  docker -H "ssh://$ssh_host:$ssh_port" login "$REGISTRY" -u "$REGISTRY_USER" -p "$REGISTRY_PASSWORD"

  # Tag previous production image as rollback
  docker -H "ssh://$ssh_host:$ssh_port" tag "$image_name" "${image_name}-rollback"

  # Pull the latest image and update the service
  docker -H "ssh://$ssh_host:$ssh_port" compose --file "$COMPOSE_FILE" pull
  docker -H "ssh://$ssh_host:$ssh_port" compose --file "$COMPOSE_FILE" up -d

  # Logout from the registry
  docker -H "ssh://$ssh_host:$ssh_port" logout "$REGISTRY"

  # Remove old images.
  docker -H "ssh://$ssh_host:$ssh_port" image prune -a

  # Check the exit code of the last docker command.
  if [ $? -ne 0 ]; then
    echo "Error updating container on $server_name."
    return 1;
  fi
  echo "Container updated successfully on $server_name."
  return 0;
}

# Main loop
while IFS= read -r server; do
  if [[ -n "$server" ]]; then # Skip empty lines
    if ! update_container "$server"; then
      echo "Update failed on server: $(echo "$server" | awk '{print $1}'). Continuing to next server."
    fi
  fi
done < "$SERVERS_FILE"

echo "Update process completed."

# Rollback function to rollback to previous production image
rollback() {
  local server_info=$1
  local server_name=$(echo "$server_info" | awk '{print $1}')
  local ssh_host=$(echo "$server_info" | awk '{print $2}')
  local ssh_port=$(echo "$server_info" | awk '{print $3}')
  local image_name=$(docker -H "ssh://$ssh_host:$ssh_port" compose --file "$COMPOSE_FILE" images | awk 'NR==2 {print $1}')

  echo "Rolling back $server_name..."

  # Rollback image
  docker -H "ssh://$ssh_host:$ssh_port" compose down
  docker -H "ssh://$ssh_host:$ssh_port" tag "${image_name}-rollback" "$image_name"
  docker -H "ssh://$ssh_host:$ssh_port" compose up -d

  # Check the exit code of the last docker command.
  if [ $? -ne 0 ]; then
    echo "Rollback failed on $server_name."
    return 1;
  fi

  echo "Rollback successful on $server_name."
  return 0;
}

# Rollback loop
rollback_all(){
  while IFS= read -r server; do
    if [[ -n "$server" ]]; then # Skip empty lines
      if ! rollback "$server"; then
        echo "Rollback failed on server: $(echo "$server" | awk '{print $1}'). Continuing to next server."
      fi
    fi
  done < "$SERVERS_FILE"
}

# Check for rollback argument
if [[ "$1" == "rollback" ]]; then
  rollback_all
  exit 0
fi

