# SetOps Bitbucket Pipelines Template

As a developer, the most convenient deployment method is a `git push` deployment.

The workflow looks like this:

* You have deployment branches such as `production` or `staging` in your source code repository.
* Each time you push to a deployment branch, a Continuous Integration (CI) pipeline will deploy your code to the respective environment.

Included is a template with customization instructions which you may use to set this workflow up on Bitbucket, using [Bitbucket Pipelines](https://bitbucket.org/product/de/features/pipelines) as your CI platform.

## Prerequisites

* The guide assumes you have already created a Stage on SetOps.
* There is a SetOps service account which can access the stage. See also [Service Account Setup](#service-account-setup).
* You have set up [Repository Variables](https://support.atlassian.com/bitbucket-cloud/docs/variables-and-secrets/) for the SetOps service account credentials, and they are named `SETOPS_USER` and `SETOPS_PASSWORD`.

## Implementation Steps

This [template](bitbucket-pipelines.yml) is made for a web application with three apps (`web`, `job`, `clock`). Each of these apps run the same source Docker image.

1. Merge the [template](bitbucket-pipelines.yml) with your existing Bitbucket Pipelines configuration in `/bitbucket-pipelines.yml`.
   
   If you do not have one yet, you can copy the template as-is.

2. Review the template.

   In particular:

   * The deployment should run at the end of existing jobs (unit tests, for example), and it should declare a dependency on previous jobs.
   * The workflow includes two ways of building a Docker image: the classic `Dockerfile` way and Cloud Native Buildpacks. Visit the guide on Docker images in the SetOps documentation to learn about both alternatives.
   * If your apps are not called `web`, `worker`, and `clock`, you need to adjust the names and add/remove the respective steps.
   * If your deployment branches differ from `staging` or `production`, you need to adjust the names.
   * If you did not configure a Container Healthcheck, replace `HEALTHY` with `RUNNING` in the `Wait for $NAME task to be healthy` steps.

3. Commit the configuration, push to a deployment branch, and enjoy automatic deployments. 

## Appendix

### Service Account Setup

You need a SetOps service account to deploy your application. This is required for the pipeline to run successfully.

1. Ask your SetOps admins for user creation and name your project repository
1. The SetOps admins will create the SetOps user and share the credentials
1. The credentials must be stored in Bitbucket as repository variables (`SETOPS_USER` and `SETOPS_PASSWORD`)
1. The SetOps admins will tell you the email of the user, you need to authorize it to your stage via `setops --stage <STAGE> user invite invalid@example.com`
