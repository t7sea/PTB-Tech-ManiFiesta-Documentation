# Cloudflare

## General information

Used for
* [Analytics](https://dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/manifiesta.be/analytics/traffic)
* [DNS management](https://dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/manifiesta.be/dns/records)
* [Certificates](https://dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/manifiesta.be/ssl-tls/edge-certificates)
* [Caching](https://dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/manifiesta.be/caching)
* [R2 object storage](https://dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/r2/overview)
* [ZeroTrust Access controls](https://one.dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/access-controls/apps)
* DDOS protection
* ...


## DNS

The manifiesta.be DNS management happens here.

This has a few implications:
1. PVDA ICT who still manages our mail (accounts) at Infomaniak, needs occasional
access to make sure the relevant DNS records are up to data for the mail service.
2. There are many records, we need some structure and metadata for each record.
We do this using tags and comments, in that order of preference.

### PVDA ICT access

This needs to be done on a personal basis, as we require 2FA to be enabled.  
To make sure they only can change DNS records, the group `PVDA ICT` was created,
granting access to only the DNS section of the manifiesta.be account/domain.

So, to add a PVDA ICT member:

1. Start invite using their mail address of preference.
2. Set account policy with
   * with scope `ManiFiesta`
   * role `Minimal Account Access`.
3. Send the invite
4. After acceptance of the invite, add the user to the `PVDA ICT` group


## R2 object storage

Used to host the public assets for the website: JSON, images,downloads,...  

There is a bucket for PROD and ACC, with custom domains assets.manifiesta.be and
assets.acc.manifiesta.be respectively.

The assets are uploaded from the corresponding Dataplatform instance.  
See [Drupal README](../../platforms/drupal/README.md) for details.


## Cache

Have a forced CF cache bypass:
* Dataplatform, PROD & ACC
* API Common, PROD & ACC
* Ticket admin & API, PROD & ACC

Force CF cache:
* Assets, PROD & ACC with except for emergency notices.
  * For 2XX response codes only
  * TTL: 5 min
  * Stale while revalidate: yes
* Robots.txt
    * TTL: 60 min
    * Stale while revalidate: yes

Have dynamic CF cache (respecting existing cache headers): anything not specified
above, including but not limited to:
* Website, PROD & ACC
* Ticket app (webversion), PROD & ACC

## Zero Trust

Access controls aretied to the Keycloak setup to only allow access to certain 
tools and/or subdomains based on a user's role in Keycloak.

This to:
* Revoke exposure of internal tools to the internet
* Make access to the Acceptance environment (ACC) easier, by eliminating the 
  need for basic authentication.

This however, makes things a bit more complex at infrastructure level:
* If we apply wildcard access check for ACC, all requests to any 
  acc.manifiesta.be subdomain need access [policies](https://one.dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/access-controls/policies).
* For client-side requests, this means setting up policies using the user's
  group from Keycloak to determine if a user has access.
* For server-side requests, [Service Credentials](https://one.dash.cloudflare.com/e3fca561a180dcb1180f18f3050c94ab/access-controls/service-credentials?tab=service-token)
  need to be setup and added to the request headers.

Therefor, we start applying this on application basis.

Currently covered:
* Website ACC
* Dataplatform ACC
