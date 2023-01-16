#!/bin/bash

# Script to create an SSH key and copy it to a remote server

# Check if .ssh directory exists, create it if it doesn't
if [ ! -d ~/.ssh ]; then
    mkdir ~/.ssh
fi

# Set default values for port and remote address
port=22
remote_address=''
remote_user=''

# Prompt user for remote server address, port, and username
read -p 'Enter remote server address: ' remote_address
read -p 'Enter remote server port (default 22): ' port
read -p 'Enter remote server username: ' remote_user

# Prompt user for key type (rsa or ed25519)
read -p 'Enter key type (rsa or ed25519): ' key_type

# Check key type and create key
if [ "$key_type" == "rsa" ]; then
    ssh-keygen -t rsa -b 4096 -C "$remote_address"
elif [ "$key_type" == "ed25519" ]; then
    ssh-keygen -t ed25519 -C "$remote_address"
else
    echo "Invalid key type. Only rsa and ed25519 are supported."
    exit 1
fi

# Get the ssh key filename
# key_file=$(ls ~/.ssh | grep -E "$key_type(-[a-zA-Z0-9]+)?")
key_file=$(ls ~/.ssh | grep -E "$key_type(-[a-zA-Z0-9]+)?.pub")


# Copy the ssh key to the remote server
ssh-copy-id -i ~/.ssh/"$key_file" -p "$port" "$remote_user"@"$remote_address"
