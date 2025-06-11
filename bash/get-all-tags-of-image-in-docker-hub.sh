
IMAGE=${1:-registry} # selfhost local repo image
wget -q -O - "https://hub.docker.com/v2/namespaces/library/repositories/${IMAGE}/tags?page_size=100" | jq -r '.results[].name'
