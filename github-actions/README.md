# GitHub Actions

As a developer, the most convenient deployment method is a `git push` deployment.

The workflow looks like this:

* You have deployment branches such as `production` or `staging` in your App's source code repository.
* Each time you push to a deployment branch, a Continuous Integration (CI) pipeline will deploy your code to the respective environment.

Included below is a template with customization instructions which you may use to setup this workflow on GitHub, using [GitHub Actions](https://docs.github.com/en/actions) as your CI platform.

## Prerequisites

* The guide assumes you have [created the Stage](/docs/user/configuration/stages).
* There is a SetOps [service account which can access the stage](/docs/user/configuration/stages/#invite-or-remove-users).
* You set up [GitHub secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#using-encrypted-secrets-in-a-workflow) for the SetOps service account credentials, and they are named `SETOPS_USER` and `SETOPS_PASSWORD`.

## Implementation Steps

1. Merge the template with your existing GitHub Actions workflow in `/.github/workflows`.

   If you do not have one yet, you can copy the template as-is.

1. Review the `TODO` markers in the workflow template. In particular:

   * The `deploy` job should run at the end of existing jobs (for example unit tests) and should have a `needs` dependency on them.

   * The workflow uses Cloud Native Buildpacks to build Docker images for the App. [Visit our guide on Docker images](/docs/user/best-practices/build-image) to learn about alternatives.

   * If your deployment branches differ from `staging` or `production`, adjust the steps at `# TODO adjust branch names & environments below`.

   * If you did not configure a [Container Healthcheck](/docs/user/configuration/apps/#container-healthcheck), replace `HEALTHY` with `RUNNING` in the `Wait for $NAME task to be healthy` steps.

   * If you need additional apps, or if your apps are named differently than `web`, `worker`, and `clock`, you need to adjust the following parameters:

      1. `env`: Merge existing ENVs and change the values of the `SETOPS_` ENVs to match your Project and Stage. Adjust all `SETOPS_WEB_$NAME`.

      1. Adjust the steps below `# ----- Create releases -----`

      1. Adjust the steps below `# ----- Activate release -----`

      1. Adjust the message at the *Summarize Deployment* step

   * Ensure there are no `# TODO` markers left from the template.

1. Commit the workflow file, push to a deployment branch, and enjoy automatic deployments. 😎
