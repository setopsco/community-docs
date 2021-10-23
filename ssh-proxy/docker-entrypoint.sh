#!/usr/bin/env bash
set -euo pipefail

main() {
  touch /etc/ssh/ssh_host_rsa_key
  chmod 0600 /etc/ssh/ssh_host_rsa_key
  base64 -d <<< "$SSH_HOST_KEY" > /etc/ssh/ssh_host_rsa_key

  echo "Setting password for user proxy..."
  echo "proxy:$SSH_PASSWORD" | chpasswd

  echo "Setting proxy config..."
  sed 's/HOST:PORT/'$SSH_FORWARD_HOST'/g' /sshd_config | tee /sshd_config
  sed 's/PROXY-PORT/'$PORT'/g' /sshd_config | tee /sshd_config
  cat /sshd_config
  cp /sshd_config /etc/ssh/sshd_config


  echo "Starting sshd..."
  exec /usr/sbin/sshd -D
}

main "$@"
