#!bin/python

from googleapiclient import discovery
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

def get_external_ips(project_id, credentials):
  """
  Retrieves a list of all external IP addresses in the specified GCP project.

  Args:
    project_id: The ID of the GCP project.
    credentials: The credentials object to use for authentication.

  Returns:
    A list of external IP addresses.
  """

  compute = discovery.build('compute', 'v1', credentials=credentials)

  external_ips = []

  # Get all zones in the project
  zones = compute.zones().list(project=project_id).execute()['items']

  for zone in zones:
    # Get all instances in the zone
    instances = compute.instances().list(project=project_id, zone=zone['name']).execute()

    # Extract external IPs from instances
    if 'items' in instances:
      for instance in instances['items']:
        if 'networkInterfaces' in instance:
          for network_interface in instance['networkInterfaces']:
            if 'accessConfigs' in network_interface:
              for access_config in network_interface['accessConfigs']:
                if 'natIP' in access_config:
                  external_ips.append(access_config['natIP'])

  # Get all static addresses in the project
  addresses = compute.addresses().list(project=project_id).execute()

  # Extract IPs from static addresses
  if 'items' in addresses:
    for address in addresses['items']:
      if 'address' in address:
        external_ips.append(address['address'])

  return external_ips


def get_all_projects(credentials):
  """
  Retrieves a list of all projects in the GCP account.

  Args:
    credentials: The credentials object to use for authentication.

  Returns:
    A list of project IDs.
  """

  cloudresourcemanager = discovery.build('cloudresourcemanager', 'v1', credentials=credentials)

  projects = cloudresourcemanager.projects().list().execute()
  project_ids = []
  if 'projects' in projects:
    for project in projects['projects']:
      project_ids.append(project['projectId'])

  return project_ids


def get_user_credentials():
  """
  Prompts the user to authenticate via an external browser and retrieves Google Account credentials.

  Returns:
    A credentials object.
  """

  flow = InstalledAppFlow.from_client_secrets_file(
      'credentials.json',  # Replace with your credentials file
      scopes=['https://www.googleapis.com/auth/cloud-platform'])

  # This will open a browser window for user authentication
  creds = flow.run_local_server(port=0)
  return creds

# Get user credentials
creds = get_user_credentials()

# Get all projects
project_ids = get_all_projects(creds)

# Get external IPs for each project
for project_id in project_ids:
  external_ips = get_external_ips(project_id, creds)
  print(f"External IPs in project {project_id}:")
  for ip in external_ips:
    print(ip)
  print("\n")


