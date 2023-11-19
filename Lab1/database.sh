#!/bin/sh

echo 'Creating VM for the database...'

az vm create --name petclinic-db --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204

echo 'Done.'

# Open ports for incoming traffic

echo 'Opening HTTP(S) ports for the VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-db  \
    --port 80 --priority 1011

az vm open-port \
    --resource-group WUS \
    --name petclinic-db  \
    --port 443 --priority 1010

az vm open-port \
    --resource-group WUS \
    --name petclinic-db  \
    --port 3306 --priority 1012

echo 'Done.'

echo 'Installing packages...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --scripts 'sudo apt update' \
    'sudo apt upgrade -y' \
    'sudo apt install mysql-server -y' \

echo 'Done.'
