#!/usr/bin/env bash
set -euo pipefail

main() {
  echo "Prepare server config"
  cat << EOF > /etc/ssh/sshd_config
Protocol 2
UseDNS no
MaxAuthTries 5
LoginGraceTime 60
MaxSessions 5
MaxStartups 10:30:60
LogLevel INFO
Subsystem sftp internal-sftp
ChrootDirectory /data
EOF

  echo "Setting port"
  echo "Port $PORT" >> /etc/ssh/sshd_config

  echo "Setting host keys"
  if [ -z "${SSH_ECDSA_HOST_KEY=}" ] && [ -z "${SSH_ED25519_HOST_KEY=}" ] && [ -z "${SSH_RSA_HOST_KEY=}" ]; then
    echo "> No host key was set. Expecting at least one of SSH_ECDSA_HOST_KEY, SSH_ED25519_HOST_KEY, SSH_RSA_HOST_KEY."
    exit 1
  fi
  if [ ! -z "${SSH_ECDSA_HOST_KEY=}" ]; then
    base64 -d <<< "$SSH_ECDSA_HOST_KEY" > /etc/ssh/ssh_host_ecdsa_key
    chmod 600 /etc/ssh/ssh_host_ecdsa_key
    echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config
  fi
  if [ ! -z "${SSH_ED25519_HOST_KEY=}" ]; then
    base64 -d <<< "$SSH_ED25519_HOST_KEY" > /etc/ssh/ssh_host_ed25519_key
    chmod 600 /etc/ssh/ssh_host_ed25519_key
    echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config
  fi
  if [ ! -z "${SSH_RSA_HOST_KEY=}" ]; then
    base64 -d <<< "$SSH_RSA_HOST_KEY" > /etc/ssh/ssh_host_rsa_key
    chmod 600 /etc/ssh/ssh_host_rsa_key
    echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config
  fi

  echo "Setting authorized_keys for user data"
  touch /etc/ssh/authorized_keys
  if [ ! -z "${SSH_AUTHORIZED_KEYS=}" ]; then
    base64 -d <<< "$SSH_AUTHORIZED_KEYS" > /etc/ssh/authorized_keys
  else
    echo "> Skipping because SSH_AUTHORIZED_KEYS is unset"
  fi
  chown data:root /etc/ssh/authorized_keys
  chmod 600 /etc/ssh/authorized_keys

  echo "Setting password for user data"
  if [ ! -z "${SSH_PASSWORD=}" ]; then
    echo "data:$SSH_PASSWORD" | chpasswd
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    echo "ChallengeResponseAuthentication yes" >> /etc/ssh/sshd_config
  else
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
    echo "> Password auth deactivated since no password was provided"
  fi

  echo "Setting user config"
  cat << EOF >> /etc/ssh/sshd_config
AllowUsers data
Match User data
  ForceCommand internal-sftp -l INFO
  AllowTcpForwarding no
  PermitTunnel no
  X11Forwarding no
  AuthorizedKeysFile /etc/ssh/authorized_keys
EOF

  printf "\n------------ Generated config ------------\n"
  cat /etc/ssh/sshd_config
  printf "\n------------------------------------------\n\n"

  echo "Starting sshd..."
  if [ "${SSH_PRINT_LOGS_TO_STDERR=}" == "true" ]; then
    exec /usr/sbin/sshd -D -e # prints logs to stderr
  else
    exec /usr/sbin/sshd -D
  fi
}

main "$@"
