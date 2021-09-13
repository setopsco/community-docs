# Graylog

This Readme and the [Dockerfile](./Docerfile) describe how to run the log management tool [Graylog](https://docs.graylog.org/en/4.0/index.html) on SetOps.

## Introductions

Set the variable client according to your SetOps environment:

```
CLIENT=<your client name>
```

Create a new project & stage. We name it `graylog` & `production` in this example:

```
setops project:create graylog
setops --project graylog stage:create production

# To simplify the usage, we use a temporary alias
alias so="setops --project graylog --stage production"
```

Create the primary app to access Graylog via API & GUI:

```
so app:create web
so --app web network:set port 9000
so --app web network:set public true
so --app web resource:set resources --cpu 1024 --memory 2048 # depends on the load on your Graylog
so --app web network:set health-check-path /api/system/lbstatus
```

Create additional apps for each [input](https://docs.graylog.org/en/4.0/pages/sending_data.html) that you want to use to ingest data. In this example, we use the GELF HTTP input:

```
so app:create gelf-input-nodes
so --app gelf-input-nodes network:set port 12201
so --app gelf-input-nodes network:set public true
so --app gelf-input-nodes resource:set resources --cpu 1024 --memory 2048 # depends on the load on your Graylog
so --app gelf-input-nodes network:set health-check-path /api/system/lbstatus
```

Define a variable `INPUTS` with all names of the previously created inputs

```
INPUTS=gelf-input-nodes
```

Generate a password secret for Graylog (we use `pwgen` but you can use any password tool for that):

```
GRAYLOG_PASSWORD_SECRET=$(pwgen -N 1 -s 96)
```

Prepare an admin password which you can later use to login:

```
GRAYLOG_ROOT_PASSWORD_SHA2=$(echo "<your secure password here>" | tr -d '\n' | sha256sum)
```

Set the environment variables. Adjust them to fit your setup:

```
# only web is primary
so --app web env:set GRAYLOG_IS_MASTER=true

for app in $INPUTS; do
  so --app "$app" env:set GRAYLOG_IS_MASTER=false
done

# configure all apps
for app in web $INPUTS; do
  # to prevent warning: Tini is not running as PID 1 and isn't registered as a child subreaper.
  so --app "$app" env:set TINI_SUBREAPER=false

  # set timezone
  so --app "$app" env:set GRAYLOG_ROOT_TIMEZONE=Europe/Berlin

  # set secrets
  so --app "$app" env:set "GRAYLOG_PASSWORD_SECRET=$GRAYLOG_PASSWORD_SECRET"
  so --app "$app" env:set "GRAYLOG_ROOT_PASSWORD_SHA2=$GRAYLOG_ROOT_PASSWORD_SHA2"

  # set external domain
  so --app web env:set "GRAYLOG_HTTP_EXTERNAL_URI=https://web.production.graylog.<SETOPS DOMAIN>/"
done
```

Create ElasticSearch service and link it to all apps:

```
so service:create es1 --type elasticsearch7 --plan t3.medium.elasticsearch

# adjust the storage space depending on your amount of logs and storage period
so --service es1 option:set storage 50

for app in web $INPUTS; do
  so --app "$app" link:create es1 --env-key GRAYLOG_ELASTICSEARCH_HOSTS
done
```

Graylog also requires MongoDB. Since SetOps currently cannot provide MongoDB due to the licence of MongoDB, it is recommended to [use MongoDB Atlas with SetOps](https://try.setops.net/docs/user/configuration/extending-setops/#mongodb-atlas). When you have created a connection string to a MongoDB database, set it for all apps:

```
for app in web $INPUTS; do
  so --app web env:set "GRAYLOG_MONGODB_URI=mongodb+srv://<USERNAME>:<PASSWORD>@<HOST>/graylog?retryWrites=true&w=majority"
done
```

Now build & release the Graylog image

```
docker build --pull -t setops-graylog .

for app in web $INPUTS; do
  docker tag setops-graylog "$CLIENT.setops.net/graylog/production/$app:latest"
  SETOPS_DIGEST=$(docker push "$CLIENT.setops.net/graylog/production/$app" | grep -o 'sha256:[a-zA-Z0-9]*')
  SETOPS_RELEASE_ID=$(so --app "$app" release:create "$SETOPS_DIGEST" | grep -o 'ReleaseID.*' | grep -o '[0-9].*')
  so --app "$app" release:activate SETOPS_RELEASE_ID
done
```

Commit your changes! Graylog should be available after a while:

```
so changeset:commit
```
