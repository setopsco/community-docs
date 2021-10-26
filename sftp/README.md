# SFTP

This is an example of deploying an SFTP service on SetOps using [OpenSSH](https://www.openssh.com/). It is helpful if you want to transfer files between an app and an SFTP client. This solution utilizes the SetOps volume service to share files between the SFTP app and another app.

## Setup

1. Create the app and make it publicly available via tcp. Only do a changeset commit after you set the protocol. Otherwise, the protocol is set to `http` and cannot be changed anymore.

    ```shell
    setops -p <PROJECT> -s <STAGE> app:create sftp

    setops -p <PROJECT> -s <STAGE> --app sftp network:set protocol tcp
    setops -p <PROJECT> -s <STAGE> --app sftp network:set public true
    setops -p <PROJECT> -s <STAGE> --app sftp network:set port 5000 # set to desired port
    ```

1. Mount the existing volume to the SFTP app to `/data`:

    ```shell
    setops -p <PROJECT> -s <STAGE> --app sftp link:create volume --path /data [--read-only]
    ```

1. Set the following environment variables via `setops -p <PROJECT> -s <STAGE> --app sftp env:set <var>:<value>`:

    |Env Name|Optional|Description|Hint|
    |---|---|---|---|
    |SSH_ECDSA_HOST_KEY|x*|SSH server host key|generate with `ssh-keygen -t ecdsa -b 521 -f key` without passphrase, encode as base64 with     `base64 --break=0 < key`|
    |SSH_ED25519_HOST_KEY|x*|SSH server host key|generate with `ssh-keygen -t ed25519 -f key` without passphrase, encode as base64 with `base64     --break=0 < key`|
    |SSH_RSA_HOST_KEY|x*|SSH server host key|generate with `ssh-keygen -t rsa -b 4096 -f key` without passphrase, encode as base64 with `base64     --break=0 < key`|
    |SSH_PASSWORD|x|(e.g. 32 character) password for authentication|generate with `pwgen 32 1`|
    |SSH_AUTHORIZED_KEYS|x|SSH public keys for authentication|generate with `ssh-keygen -t rsa -b 4096 -f key` without passphrase, encode as base64 with     `base64 --break=0 < key`|
    |SSH_PRINT_LOGS_TO_STDERR|x|Enable logs (to stderr)|set to `true` to activate|

    \* At least one of the host keys needs to be set. To offer the most complete algorithm support, provide all three.

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
- Port: the port you set in the step 1 – also available via `setops -p <PROJECT> -s <STAGE> app:info sftp` (_App Network Port_)
