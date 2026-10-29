# General setup file for keycloak

Current setup: Hosted on DigitalOcean using a Keycloak Droplet with modified
Dockerfile.


## Table of contents

- [Upgrading the ubuntu version](#upgrading-the-ubuntu-version)
- [Updating or upgrading keycloak](#updating-or-upgrading-keycloak)
- [Updating our custom Keycloak theme](#updating-our-custom-keycloak-theme)
- [Installing Keycloak](#installing-keycloak)


## Upgrading the ubuntu version

This is a first simple upgrade to make sure we're on ubuntu 24 instead of 22. 
This will provide us with security updates until 2029. Don't upgrade to ubuntu 26, 
we will wait at least until 2027 for a more stable transition.

```
apt update && apt upgrade -y && do-release-upgrade
```

While do-release-update was paused at this message:

```
Third party sources disabled

Some third party entries in your sources.list were disabled. You can re-enable them after the upgrade with the ‘software-properties’ tool or your package manager.
To continue please press [ENTER]
```

Go to /etc/apt/sources.list

Uncomment all the references to mirrors.digitalocean.com and change them from 
jammy to noble


## Updating or upgrading keycloak

Before starting, screen the [Release Notes](https://www.keycloak.org/docs/latest/release_notes/)
for any changes that might be of impact to us, or provide enough reason to 
postpone. If so, communicate this with the team, so a plan to handle this can
be devised.

Check the [repository](https://quay.io/repository/keycloak/keycloak?tab=tags&tag=latest) 
for desired release tag.  
We will stay with version 26 for now. So taking the latest point release (currently 26.8.0).

1. Edit the reference [Dockerfile](Dockerfile/Dockerfile) to use the latest 
version by updating the image version on the first line:
```
ARG KEYCLOAK_VERSION=26.8.0
```

Apply the same version number change to all occurences in this file.


2. Review the disable feature line with the default feature list of the release,
to disable as much as possible that we really don't need:
```
RUN /opt/keycloak/bin/kc.sh build --features-disabled="ciba,client-auth-federated,identity-brokering-api,kerberos,kubernetes-service-accounts,opentelemetry,organization,step-up-authentication-saml,twitter-broker"
```

3. In the Droplet on DigitalOcean, Dockerfile at `/var/digitalocean/Dockerfile`:
- Take note of the values of `KC_DB_PASSWORD` and `KC_HOSTNAME`.
- Replace the fike with the new version. 
- Restore the values of `KC_DB_PASSWORD` and `KC_HOSTNAME`

4. In `/var/digitalocean`, rebuild the image using the version in the image name
(for later reference):
```
docker build -t local-keycloak-themed:26.8.0 .
```

5. Stop the current container and remove the old image:
```
docker stop keycloak
docker rm keycloak
```

6. Start from the new image:

ACCPT:
```
docker run -d --network=host \
  --name keycloak \
  local-keycloak-themed:26.8.0 \
  start \
  --optimized
```

PROD:
```
docker run -d --network=host \
  --name keycloak \
  local-keycloak-themed:26.8.0 \
  start \
  --optimized
```

7. Test the updated Keycloak:
- Master realm login
- Public realm login
- User login via website or application that uses it.

8. Cleanup obsolete images and containers
```
docker system prune
```

9. Commit the changes to this and the reference [Dockerfile](Dockerfile/Dockerfile).


## Updating our custom Keycloak theme

1. Update the custom theme files in `/var/digitalocean/themes`
2. Rebuild the customized image, as described in section 'Updating or 
   upgrading keycloak' from step 4.


## Installing Keycloak

Using a temporary DNS name, with the idea to get a default setup in the future.
This example uses `keycloak.acc.manifiesta.be`, to be replaced with the appropriate
domain.

1. Create the necessary nginx files copied from the original Keycloak setup, and 
enable them:

``` 
mkdir -p /var/www/keycloak.acc.manifiesta.be/html
cp /etc/nginx/sites-available/keycloak /etc/nginx/sites-available/keycloak.acc.manifiesta.be
```

Add `keycloak.acc.manifiesta.be` as server_name:

```
ln -s /etc/nginx/sites-available/keycloak.acc.manifiesta.be /etc/nginx/sites-enabled/keycloak.acc.manifiesta.be
systemctl restart nginx
```

Get the necessary certificate:

```
certbot --nginx -d keycloak.acc.manifiesta.be
```

This process will also update the nginx files.
Some more updates are required, here is the current full file:

```
server {
    server_name keycloak.acc.manifiesta.be;

    location ^~ /.well-known {
        allow all;
    }

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/keycloak.acc.manifiesta.be/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/keycloak.acc.manifiesta.be/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
    listen 9001;
    server_name keycloak.acc.manifiesta.be;

    location ~ /.well-known {
        allow all;
    }

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
server {
    if ($host = keycloak.acc.manifiesta.be) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name keycloak.acc.manifiesta.be;
    return 404; # managed by Certbot


}
```
Find the current full versions:
- [keycloak.acc.manifiesta.be](acc/etc/nginx/sites-available/keycloak.acc.manifiesta.be)
- [keycloak.manifiesta.be](prod/etc/nginx/sites-available/keycloak.manifiesta.be)


Now we need to change the hostname of the docker image.  
Make sure to get the current environment variables of the docker. We need the 
passwords by finding them in de Config.Env.

Make sure to check the upcoming docker run command first and make sure you have 
all the necessities.

```
docker inspect keycloak
```

Now once copied, we can stop and remove the current Keycloak and build the new one:

```
docker stop keycloak
docker rm keycloak
```

Create a Dockerfile at `/var/digitalocean/Dockerfile` using our template
[Dockerfile](./Dockerfile/Dockerfile):
- Update the source image/Keycloak version if necessary
- Set actual `DB_PASSWORD` and `HOSTNAME` values.


Rebuild the image using the version in the image name (for later reference):
```
docker build -t local-keycloak-themed:26.8.0 .
```

Start from the new image:
```
docker run -d --network=host \
  --name keycloak \
  local-keycloak-themed:26.8.0 \
  start \
  --optimized
```

On the very first run, you may need to boot with the bootstrap admin password. 
However, this should've been set on container creation by DigitalOcean.  
In my case it wasn't necessary.

```
docker run -d --network=host \
  --name keycloak \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=(copied from previous env) \
  local-keycloak \
  start \
  --optimized
```
