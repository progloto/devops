# **Install private registry**

# **Install on server**

See registry config doc [here](https://github.com/GerritForge/docker-registry/blob/master/docs/configuration.md)  
Prepare the External Directory

```
adduser --disabled-password --gecos "" online
sudo mkdir -p /data/docker-registry
sudo chown 1000:1000 /data/docker-registry # Docker registry runs as user 1000
```

Obtain TLS Certificates  
Local self signed

```
openssl req -x509 -newkey rsa:4096 -nodes -sha256 -days 365 -keyout registry.key -out registry.crt -subj "/CN=yourregistry.example.com"
sudo mkdir -p /certs
sudo mv registry.crt /certs/registry.crt
sudo mv registry.key /certs/registry.key
```

Free letsencrypt with certbot

```
apt -y install certbot mc screen curl
certbot certonly --standalone -d registry.99digital.co.il  --agree-tos -n --email vadim+99d@vadiaz.com

```

Successfully received certificate.  
Certificate is saved at: /etc/letsencrypt/live/registry.99digital.co.il/fullchain.pem  
Key is saved at:         /etc/letsencrypt/live/registry.99digital.co.il/privkey.pem

Basic Authentication (using `htpasswd`)

```
sudo apt-get install apache2-utils # For Debian/Ubuntu
REGPASSWORD=<secure password>
mkdir -p /data/auth
cd /data/auth
htpasswd -c htpasswd deploy99digital

# or user container
docker run \
  --entrypoint htpasswd \
  httpd:2 -Bbn deploy99digital $REGPASSWORD > /data/auth/htpasswd

```

Start registry instance

```
docker run -d -p 443:5000 --restart=always  --name registry-99d \
  -v /data/docker-registry:/var/lib/registry \
  -v /etc/letsencrypt:/certs \
  -v /data/auth:/auth \
  -e REGISTRY_HTTP_SECRET=$REGPASSWORD \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/live/registry.99digital.co.il/fullchain.pem \
  -e REGISTRY_HTTP_TLS_KEY=/certs/live/registry.99digital.co.il/privkey.pem \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry 99 Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2
```

# **Use on client**

```
# For self signed cert install it on client docker
#sudo mkdir -p /etc/docker/certs.d/yourregistry.example.com
#sudo cp registry.crt /etc/docker/certs.d/yourregistry.example.com/ca.crt
#sudo systemctl restart docker


docker login registry.99digital.co.il -u deploy99digital -p $REGPASSWORD

docker tag chatwoot registry.99digital.co.il/online
docker push registry.99digital.co.il/online

# on servers
docker login registry.99digital.co.il -u deploy99digital -p $REGPASSWORD
docker pull registry.99digital.co.il/online
```

