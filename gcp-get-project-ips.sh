#!/bin/bash

# Get a list of all projects
projects=$(gcloud projects list --format="value(projectId)")

# Loop through each project
for project in $projects; do
  echo "Project: $project"

  # Get static external IPs
  echo "  Static External IPs:"
  gcloud compute addresses list --project="$project" --filter="NOT addressType:INTERNAL"

  # Get external IPs of instances (including ephemeral)
  echo "  Instance External IPs:"
  gcloud compute instances list --project="$project" --format=json | jq -r '.[].networkInterfaces[].accessConfigs[].natIP'

  echo "" # Add an empty line for better readability
done

