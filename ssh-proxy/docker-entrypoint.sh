#!/usr/bin/env bash
set -euo pipefail

main() {
  echo "Setting ssh host-key..."
  touch /etc/ssh/ssh_host_rsa_key
  chmod 0600 /etc/ssh/ssh_host_rsa_key
  base64 -d <<< "$SSH_HOST_KEY" > /etc/ssh/ssh_host_rsa_key

  echo "Setting ssh authorized_keys..."
  touch /app/authorized_keys
  if [ -z ${SSH_AUTHORIZED_KEYS+x} ]; then
    echo "Skipping because SSH_AUTHORIZED_KEYS is unset...";
  else
    base64 -d <<< "$SSH_AUTHORIZED_KEYS" > /app/authorized_keys
  fi

  echo "Setting password for user proxy..."
  echo "proxy:$SSH_PASSWORD" | chpasswd

  local regexp='postgres(ql)?\:\/\/([A-Za-z0-9_\-]*)\:([A-Za-z0-9_\-]*)\@([A-Za-z0-9_\.\-]*):?([0-9]*)?\/([A-Za-z0-9_\-]*)'
  if [[ $DATABASE_URL =~ $regexp ]]; then

    export DATABASE_HOST="${BASH_REMATCH[4]}"
    export DATABASE_PORT="${BASH_REMATCH[5]:-5432}"

    echo "Setting proxy config..."
    sed -i 's/HOST:PORT/'$DATABASE_HOST':'$DATABASE_PORT'/g' /sshd_config
    sed -i 's/PROXY-PORT/'$PORT'/g' /sshd_config
    cat /sshd_config
    cp /sshd_config /etc/ssh/sshd_config

    echo "Starting sshd..."
    exec /usr/sbin/sshd -D
  else
    echo "Coud not extract forwarding host from DATABASE_URL env. Exiting..."
    exit 1
  fi
}

main "$@"
