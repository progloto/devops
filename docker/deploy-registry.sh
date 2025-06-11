# start standalone registry as container on current host
# registry data is persistent in /var/lib/registry
docker run -d -p 443:5000 --restart=always  --name registry-99d   -v /data/docker-registry:/var/lib/registry   -v /etc/letsencrypt:/certs   -v /data/auth:/auth   -e REGISTRY_HTTP_SECRET=COMMA-ot-Dic-maul-Etsh-ONE   -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/live/registry.99digital.co.il/fullchain.pem   -e REGISTRY_HTTP_TLS_KEY=/certs/live/registry.99digital.co.il/privkey.pem   -e REGISTRY_AUTH=htpasswd   -e REGISTRY_AUTH_HTPASSWD_REALM="Registry 99 Realm"   -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd   registry:2

