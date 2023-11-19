#!/bin/sh

# Create resource group

echo 'Creating resource group for the infrastructure...'
az group create -l uksouth -n WUS
echo 'Done'

# Create vnet and subnet

echo 'Creating subnet for petclinic infrastructure...'
az network vnet create \
    --name petclinic-vnet \
    --resource-group WUS \
    --address-prefix 10.0.0.0/16 \
    --subnet-name petclinic-subnet \
    --subnet-prefixes 10.0.0.0/24
echo 'Done.'

echo 'Creating VM for the database...'

az vm create --name petclinic-db --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --public-ip-address "" \
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.6

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

az vm run-command invoke  --command-id RunShellScript --name petclinic-db -g WUS  \
    --scripts 'sudo apt update' \
    'sudo apt upgrade -y' \
    'sudo apt install mysql-server -y' \

echo 'Done.'

echo 'Creating VM for back-end...'

az vm create --name petclinic-backend --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --public-ip-address "" --vnet-name petclinic-vnet \
    --subnet petclinic-subnet --private-ip-address 10.0.0.5

echo 'Done.'

# Open ports for incoming traffic

echo 'Opening HTTP(S) ports for the VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port 80 --priority 1011

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port 443 --priority 1010

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port 9966 --priority 1012

echo 'Done.'

echo 'Installing packages...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --scripts 'sudo apt update' \
    'sudo apt upgrade -y' \
    'sudo apt install openjdk-17-jdk openjdk-17-jre -y' \
    'sudo apt install maven -y' \

echo 'Done.'

echo 'Running project...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --scripts 'git clone https://github.com/bkisly/spring-petclinic-rest' \
    'cd spring-petclinic-rest/' \
    'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/' \
    './mvnw spring-boot:run &' \

echo 'Done.'

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
    'git clone https://github.com/bkisly/spring-petclinic-angular.git' \
    'cd spring-petclinic-angular/' \
    'npm install --save-dev @angular/cli@latest --force' \
    'rm package-lock.json' \
    'npm install --force' \
    'echo N | ng analytics off' \
    'echo Y | sudo ng serve --host 0.0.0.0 --port 80 &'

echo 'Done.'
