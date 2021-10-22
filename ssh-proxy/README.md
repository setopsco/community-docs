# ssh-proxy

## Setup

1. Create the app and make it public available via tcp. Only do a changeset commit after you set you protocol. Otherwise the protocol is set to `http` and cannot be changed anymore.

    ```text
    sos app:create proxy

    sos --app proxy network:set protocol tcp
    sos --app proxy network:set public true
    ```

1. Link the database to the proxy app:

    ```text
    sos link:create database --app proxy --env-key DATABASE_URL
    ```

1. Set the environment variables:

    ```text
    SSH_FORWARD_HOST: <Databasehost>:<Databaseport>
    SSH_HOST_KEY: <see hint>
    SSH_PASSWORD: <see hint>
    SSH_PROXY_PORT: <SetOps Network Port, can be found under `sos app:info proxy`>
    NO_VHOST: '1'
    ```

    > Hint:
    >
    > `SSH_HOST_KEY`: SSH server host key (generate with `ssh-keygen -t rsa -b 4096 -f key` without passphrase), encode to base64 with `base64 --break=0 < key`
    >
    > `SSH_PASSWORD`: random 16 character password (generate with `pwgen 16 1`)

    Use the `sos --app proxy env:set <var>:<value>` to set the values. You can get the database host, port and credentials by running something like `sos --app <app> task:run --entrypoint sh -- -c "printenv"` in an already existing app.

1. Deploy the proxy using:

    ```text
    docker build -t zweitag.setops.net/<project>/<stage>/proxy .
    docker push zweitag.setops.net/<project>/<stage>/proxy

    sos --app proxy release:create sha256:<sha>
    sos --app proxy release:activate 1
    ```

## Connection

To connect to the ssh-server, use the following settings:

- Server: run `sos --app proxy domain` to get the domain
- User: `proxy`
- Password: see environment variable `SSH_PASSWORD`
- Port: see environment variable `SSH_PROXY_PORT`

To connect to the database, extract the following values from the `DATABASE_URL` environment variable:

- Host
- Port
- User
- Password
- Database

An example connection using using [Table Plus](https://www.tableplus.io/download) can be found in the picture below:

![Connection Screen](assets/connection1.png)

If using PuTTY, remember to set the following option:

![PuTTY SSH Tunnel](assets/connection2.png)
