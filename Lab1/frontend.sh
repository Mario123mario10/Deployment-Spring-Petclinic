#!/bin/sh

# Create a VM for front-end

echo 'Creating VM for front-end...'

az group create -l uksouth -n WUS
az vm create --name petclinic-frontend --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --public-ip-sku Standard \
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.4

echo 'Done.'

# Open ports for incoming traffic

echo 'Opening HTTP(S) ports for the VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-frontend  \
    --port 80 --priority 1011

az vm open-port \
    --resource-group WUS \
    --name petclinic-frontend  \
    --port 443 --priority 1010

echo 'Done.'

echo 'Installing packages...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-frontend -g WUS  \
    --scripts 'sudo apt update' \
    'sudo apt upgrade -y' \
    'sudo apt install npm -y' \
    'sudo sudo npm cache clean -f' \
    'sudo npm install -g n' \
    'sudo n stable' \
    'hash -r' \

echo 'Done.'

echo 'Installing project packages and launching the app...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-frontend -g WUS  \
    --scripts 'npm uninstall -g angular-cli @angular/cli' \
    'npm install -g @angular/cli@latest' \
    'git clone https://github.com/spring-petclinic/spring-petclinic-angular.git' \
    'cd spring-petclinic-angular/' \
    'npm install --save-dev @angular/cli@latest --force' \
    'rm package-lock.json' \
    'npm install --force' \
    'echo N | ng analytics off' \
    'echo Y | sudo ng serve --host 0.0.0.0 --port 80 &'

echo 'Done.'
