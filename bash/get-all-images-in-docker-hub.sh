
wget -q -O - "https://hub.docker.com/v2/namespaces/library/repositories?page_size=100" |jq -r '.results[].name'
wget -q -O - "https://hub.docker.com/v2/namespaces/library/repositories?page_size=100&page=2" |jq -r '.results[].name'

