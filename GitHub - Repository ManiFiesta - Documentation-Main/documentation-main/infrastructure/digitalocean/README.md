# DigitalOcean

## General information

Used for hosting of
* Website: PROD & ACC
* Dataplatform (Drupal): PROD & ACC
* Matomo: PROD
* Keycloak: ACC
* All webversions of the apps, their APIs and backends (if any)
* Managed databases for any of the above

We use:
* The [App platform](https://cloud.digitalocean.com/apps?i=61cd83) for Javascript
based applications.
* [Droplets](https://cloud.digitalocean.com/droplets?i=61cd83) for the more heavy
  stuff like Drupal, Matomo,...
* [Databases](https://cloud.digitalocean.com/databases?i=61cd83) for managed databases for the apps.

All application are assigned to either [Production](https://cloud.digitalocean.com/projects/7dda19ea-9c97-4233-9881-1620225fd5ad/resources?i=61cd83)
or [Acceptance](https://cloud.digitalocean.com/projects/7dda19ea-9c97-4233-9881-1620225fd5ad/resources?i=61cd83)
_projects_ for easy comparison.


## URL naming conventions

To help ourself in remembering which (sub)domain belongs to what kind of
application, whether it is the PROD or ACC version, a few naming rules have been
established:

1. All ACC copies of anything, need to be a direct subdomain of `acc.manifiesta.be`.
All PROD copies of anything, are a direct subdomain of `manifiesta.be`.  
For example: `dataplatform.acc.manifiesta.be` versus `dataplatform.manifiesta.be`

2. API/middleware applications are direct subdoman of `api.manifiesta.be` for
PROD and `api.acc.manifiesta.be` ACC, respecting the previous rule.  
For example: `tickets.api.manifiesta.be` versus `tickets.api.acc.manifiesta.be`

3. Spaces or other dividers in the name are replaced with a dash `-`.  
For example: `tickets-admin.acc.manifiesta.be`

Any subdomain following these rules will be covered by existing wildcard SSL 
certificates in [Cloudflare Edge Certificates](https://dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/manifiesta.be/ssl-tls/edge-certificates).


## Updating and deployment

* All apps on the App Platform have auto deployment on commit/push to the
`production` and `acceptance` branches.
* Droplets themselves (Ubuntu) need to be manually updated.
* Droplet contents depend on what is runnning in the Droplet. See the READMEs
of the respective platforms.
* Databases are managed so they are automatically scheduled for update, although
manually trigger of the update is also possible.


## Databases

## Postgres

https://docs.digitalocean.com/products/databases/postgresql/how-to/modify-user-privileges/
https://docs.digitalocean.com/support/how-do-i-fix-a-permission-denied-for-schema-public-error-in-postgresql/