#!/bin/bash

CONFIG_DIR_TXT="~/.ssh/sealos/"
CONFIG_DIR=~/.ssh/sealos/
SSH_CONFIG_FILE=~/.ssh/config

CONFIG_FILE_TXT="${CONFIG_DIR_TXT}devbox_config"
CONFIG_FILE=${CONFIG_DIR}devbox_config

PRIVATE_KEY="-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtz
c2gtZWQyNTUxOQAAACCknsEJlxl8B+6dEA8dsv0y3Uz5pH2G4H/ILM8/dRZbtAAA
AIh3Znhzd2Z4cwAAAAtzc2gtZWQyNTUxOQAAACCknsEJlxl8B+6dEA8dsv0y3Uz5
pH2G4H/ILM8/dRZbtAAAAECcxxhDq+Se85Ggu7Ubd97gYb1gjHjguizPTnyGeL93
/aSewQmXGXwH7p0QDx2y/TLdTPmkfYbgf8gszz91Flu0AAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
"
NAME="devbox.us-east-1.clawcloudrun.com_ns-x5jkm6r3_devbox"
HOST="devbox.us-east-1.clawcloudrun.com"
PORT="30107"
USER="devbox"

IDENTITY_FILE_TXT="${CONFIG_DIR_TXT}$NAME"
IDENTITY_FILE="${CONFIG_DIR}$NAME"
HOST_ENTRY="
Host $NAME
  HostName $HOST
  Port $PORT
  User $USER
  IdentityFile $IDENTITY_FILE_TXT
  IdentitiesOnly yes
  StrictHostKeyChecking no"

mkdir -p $CONFIG_DIR

if [ ! -f "$CONFIG_FILE" ]; then
    touch "$CONFIG_FILE"
    chmod 0644 "$CONFIG_FILE"
fi

if [ ! -f "$SSH_CONFIG_FILE" ]; then
    touch "$SSH_CONFIG_FILE"
    chmod 0600 "$SSH_CONFIG_FILE"
fi

if [ ! -s "$SSH_CONFIG_FILE" ]; then
    echo -e "Include $CONFIG_FILE_TXT\n" >> "$SSH_CONFIG_FILE"
else
    if ! grep -q "Include $CONFIG_FILE_TXT" "$SSH_CONFIG_FILE"; then
        temp_file="$(mktemp)"
        echo "Include $CONFIG_FILE_TXT" > "$temp_file"
        cat "$SSH_CONFIG_FILE" >> "$temp_file"
        mv "$temp_file" "$SSH_CONFIG_FILE"
    fi
fi

echo "$PRIVATE_KEY" > "$IDENTITY_FILE"
chmod 0600 "$IDENTITY_FILE"

if grep -q "^Host $NAME" "$CONFIG_FILE"; then
    temp_file="$(mktemp)"
    awk '
        BEGIN { skip=0 }
        /^Host '"$NAME"'$/ { skip=1; next }
        /^Host / {
            skip=0
            print
            next
        }
        /^$/ {
            skip=0
            print
            next
        }
        !skip { print }
    ' "$CONFIG_FILE" > "$temp_file"
    echo "$HOST_ENTRY" >> "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
else
    echo "$HOST_ENTRY" >> "$CONFIG_FILE"
fi