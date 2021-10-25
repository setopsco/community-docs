# SFTP

This is an example of deploying an SFTP service on SetOps using [OpenSSH](https://www.openssh.com/). It is helpful if you want transfer files between an app and a SFTP client. This solution utilizes the SetOps volume service to share files between the SFTP app and another app.

## Setup

1. Create the app and make it public available via tcp. Only do a changeset commit after you set the protocol. Otherwise the protocol is set to `http` and cannot be changed anymore.

    ```shell
    setops -p <PROJECT> -s <STAGE> app:create sftp

    setops -p <PROJECT> -s <STAGE> --app sftp network:set protocol tcp
    setops -p <PROJECT> -s <STAGE> --app sftp network:set public true
    setops -p <PROJECT> -s <STAGE> --app sftp network:set port 12345
    ```

1. Mount the existing volume to the SFTP app to `/data`:

    ```shell
    setops -p <PROJECT> -s <STAGE> --app sftp link:create volume --path /data [--read-only]
    ```

1. Set the environment variables:

    ```text
    # one of
    SSH_ECDSA_HOST_KEY: <see hint>
    SSH_ED25519_HOST_KEY: <see hint>
    SSH_RSA_HOST_KEY: <see hint>

    (optional) SSH_PASSWORD: <see hint>
    (optional) SSH_AUTHORIZED_KEYS: <see hint>
    ```

    > Hint:
    >
    > `SSH_ECDSA_HOST_KEY`: SSH server host key (generate with `ssh-keygen -t ecdsa -b 521 -f key` without passphrase), encode to base64 with `base64 --break=0 < key`
    > `SSH_ED25519_HOST_KEY`: SSH server host key (generate with `ssh-keygen -t ed25519 -f key` without passphrase), encode to base64 with `base64 --break=0 < key`
    > `SSH_RSA_HOST_KEY`: SSH server host key (generate with `ssh-keygen -t rsa -b 4096 -f key` without passphrase), encode to base64 with `base64 --break=0 < key`
    >
    > `SSH_PASSWORD`: random (e.g. 16 character) password (generate with `pwgen 16 1`)
    >
    > `SSH_AUTHORIZED_KEYS`: SSH public keys files, encode to base64 with `base64 --break=0 < authorized_keys`

    Use the `setops -p <PROJECT> -s <STAGE> --app sftp env:set <var>:<value>` to set the values. The port of the SFTP server is gathered by using the `$PORT` environment variables.

1. Commit your changes with `setops -p <PROJECT> -s <STAGE> changeset:commit`.

1. Build & Deploy the SFTP app using:

    ```shell
    docker build -t <CLIENT>.setops.net/<PROJECT>/<STAGE>/sftp .
    docker push <CLIENT>.setops.net/<PROJECT>/<STAGE>/sftp

    setops -p <PROJECT> -s <STAGE> --app sftp release:create sha256:<sha>
    setops -p <PROJECT> -s <STAGE> --app sftp release:activate 1
    setops -p <PROJECT> -s <STAGE> changeset:commit
    ```

## Connection

To connect to the SFTP server, use the following settings:

- Server: run `setops -p <PROJECT> -s <STAGE> --app sftp domain` to get the domain
- User: `data`
- Auth: either use the password you provided (via the `SSH_PASSWORD` env variable) or a client with the your SSH private key
- Port: see App Network Port (`app:info sftp`, default `5000`)
