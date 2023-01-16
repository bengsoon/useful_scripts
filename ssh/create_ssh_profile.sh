#!/bin/bash

# Script to create an SSH config profile

# Prompt user for remote server address, port, and username
read -p 'Enter remote server address: ' remote_address
read -p 'Enter remote server port (default 22): ' port
read -p 'Enter remote server username: ' remote_user

# Array to store port forwarding
port_forwarding_array=()

# Prompt user for port forwarding
while true; do
    read -p 'Enter port forwarding (example: 8888:8888), or leave blank to finish: ' port_forward
    if [ -z "$port_forward" ]; then
        break
    fi
    local_port=$(echo $port_forward | cut -f1 -d:)
    remote_port=$(echo $port_forward | cut -f2 -d:)
    port_forwarding_array+=("$local_port localhost:$remote_port")
done

# Prompt user for identity file
echo "Select the identity file:"

# List the ssh key files in the .ssh directory
i=1
for file in ~/.ssh/*; do
    echo "$i) $(basename $file)"
    i=$((i+1))
done

# Prompt user to select the identity file
read -p 'Enter the number of the identity file: ' identity_file_index

# Get the identity file path
identity_file=$(ls ~/.ssh | sed -n "${identity_file_index}p")
identity_file_path=~/.ssh/$identity_file

# Prompt user to give a name to the ssh config profile
read -p "Enter the name of the ssh file (default '$remote_address'): " ssh_profile_name
if [ -z "$ssh_profile_name" ]; then
	ssh_profile_name="$remote_address"
fi

#Check if the profile already exists in the config file
if grep -qw "^Host $ssh_profile_name" ~/.ssh/config; then
    echo "Error: Profile $ssh_profile_name already exists in the config file."
    exit 1
fi


# Create the SSH config profile
echo "
Host $ssh_profile_name
    HostName $remote_address
    Port $port
    User $remote_user
    IdentityFile $identity_file_path
" >> ~/.ssh/config

# Append port forwarding to the SSH config profile
for port_forward in "${port_forwarding_array[@]}"; do
    echo "    LocalForward $port_forward" >> ~/.ssh/config
done

echo "SSH config profile for '${ssh_profile_name}' created."
echo "You can now connect to your remote machine by typing in 'ssh ${ssh_profile_name}'."
