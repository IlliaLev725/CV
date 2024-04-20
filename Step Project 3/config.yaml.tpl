#cloud-config
fqdn: ${hostname}
package_update: true
package_upgrade: true
# preserve_hostname: true
packages:
  - awscli
  - docker.io

users:
  - name: illia
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCJPskvY9BF1DpP95m7e41NKXkT8tiXwd3ED+q9WKbqNGvJX0BOL7/ktGUsNb70UFoVhzboMnFeqF2JcvAs69uyRmva2JZjvjV60PCltXd5+uQT6G/wZebhL7BT3njeMJnd5Y/OUzg4lUapMkpO0QlZeoKmK0M4EYWdTat6OgUw8Sfq2fdlj4XTFC4dh1vqh6Y/gdbELcqPYQlBcLbsq8M+1FSaqUaR1VhnrlHNFNvyRV/pkaaCeKSVM1eG3TrKpZiOxQqgMZMsoPtcdV3PMSv/Nu+E3KW8QmOUvN+j9uXTtJz1SR9hvaCj2pHpBvHdqmViq8JojYZ6NQ0AyY/O0kVjU18THxx65eBnHWGMfsuWP7j1EC0e73XguhsmRsy8lR8RUGWP3MPFoyO+jaT8S6+fwJpnuyAi3HxT63j56cCiyAtM7qTrNaudIc4tgAKwTlzuyEpDKYGGw87QhtL+ND8EhhP6RgY1+28jcDEyBIiiDjv4qrDocTMgBg4NxKD5pFk= illia@VM1
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: sudo
    shell: /bin/bash

write_files:
  - path: /etc/ssh/sshd_config
    content: |
      Port ${ssh_listen_port}
      Protocol 2
      HostKey /etc/ssh/ssh_host_rsa_key
      HostKey /etc/ssh/ssh_host_dsa_key
      HostKey /etc/ssh/ssh_host_ecdsa_key
      HostKey /etc/ssh/ssh_host_ed25519_key
      UsePrivilegeSeparation yes
      KeyRegenerationInterval 3600
      ClientAliveInterval 120
      ServerKeyBits 1024
      SyslogFacility AUTH
      LogLevel INFO
      LoginGraceTime 120
      PermitRootLogin no
      StrictModes yes
      RSAAuthentication yes
      PubkeyAuthentication yes
      IgnoreRhosts yes
      RhostsRSAAuthentication no
      HostbasedAuthentication no
      PermitEmptyPasswords no
      ChallengeResponseAuthentication no
      MACs hmac-sha1,hmac-sha2-256,hmac-sha2-512
      X11Forwarding no
      X11DisplayOffset 10
      PrintMotd no
      PrintLastLog yes
      TCPKeepAlive yes
      AcceptEnv LANG LC_*
      Subsystem sftp /usr/lib/openssh/sftp-server
      UsePAM yes

runcmd:
  - systemctl restart ssh

