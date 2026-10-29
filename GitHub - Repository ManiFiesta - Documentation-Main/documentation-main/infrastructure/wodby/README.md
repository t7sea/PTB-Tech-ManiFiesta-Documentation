# Wodby

## General information

Used to manage technology stacks hosting in Droplets at Digital Ocean, for 
Drupal and Matomo:

* Wodby provides optimized stacks for Drupal, Matomo but also other kind of
platforms.
* Wodby handles updating and deployment of these stacks, with options for
* customization.

We use [Wodby 1.0](https://wodby.com/docs/1.0/)!

## Drupal

We use a [custom stack](https://cloud.wodby.com/stacks/ea867f20-24bb-4d7e-b6f1-803867cec2c7/edit), 
but try to keep it as much as possible in sync with the reference Drupal stack.

The reason for the customizations are:
* We need additional packages in the Php containers for Cron and SSH.
* We need to execute custom scripts when preparing the Cron and SSH images.
* Place a different `settings.local.php` for PROD and ACC.

All of this is handled by combination of 
* [Github Actions workflows](https://github.com/manifiesta/dataplatform-2023/tree/production/.github/workflows)
for PROD and ACC
* using [Wodby CI](https://wodby.com/docs/1.0/apps/deploy/#wodby-cli) in the
workflows
* custom [Dockerfile](https://github.com/manifiesta/dataplatform-2023/blob/production/Dockerfile)
to build the customized Php images
* custom [scripts](https://github.com/manifiesta/dataplatform-2023/tree/production/workflow)
used in the workflow.

Copies of the stack defintions:
* [The current reference](Drupal11-6.2.1-template.yml)
* [Our customized version](Drupal11-php8.4-node24.yml)


## Deployment

Deployment happens in two steps:
1. The Github Actions workflow prepares the codebase for the respective
environment, build images from it and push those to the Wodby registry.
2. Wodby CI/CD then deploys the new images to the Droplet and runs [post-deploy
commands](https://github.com/manifiesta/dataplatform-2023/blob/production/wodby.yml).

Any push/commit to `acceptance` branch will trigger the ACC workflow, thus
auto deploying the update.  

__For PROD, manual trigger is alway required.__  
Always run the [PROD workflow](https://github.com/manifiesta/dataplatform-2023/actions/workflows/ci-wodby-prod.yml)
on the `production` branch (there seems to be no way to hide the other branches)!

### Stack updates
This is mainly performed in the Wodby control panel.  

The steps usually are:
* Update the custom stack definition.
* Update the ACC Dataplatform definition to use the new stack version
* Redeploy the ACC Dataplatform via Github Actions or by pushing a codebase update, to actually rebuild the stack in the Droplet.
* When all is well, repeat for PROD.


## Matomo

We use the default stack with a preinstalled Matomo.

Updating Matomo consists of:
* Updating and deploying the stack.
* Review the [System Check page](https://matomo.manifiesta.be/index.php?module=Installation&action=systemCheckPage)
in Matomo, and look for post-update issue notifications. There usually are
problems with files
that could not automatically be deleted as part of the update step and need to
be removed manually.
The issue notifications should provide the necessary commands to resolve the
problem.
* If there are files to delete, [ssh into the Droplet](https://cloud.digitalocean.com/droplets/409572231/access?i=61cd83)
and execute the provided commands + refresg tge System Check page to make sure
the issues are resolved.
