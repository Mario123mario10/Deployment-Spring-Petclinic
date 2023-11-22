#!/bin/sh

# CREATE RESOURCE GROUP

echo 'Creating resource group for the infrastructure...'
az group create -l uksouth -n WUS
echo 'Done'

# CONFIGURE SUBNETTING

echo 'Creating subnet for petclinic infrastructure...'
az network vnet create \
    --name petclinic-vnet \
    --resource-group WUS \
    --address-prefix 10.0.0.0/16 \
    --subnet-name petclinic-subnet \
    --subnet-prefixes 10.0.0.0/24
echo 'Done.'

# CONFIGURE DATABASE

echo 'Creating VM for the database...'

az vm create --name petclinic-db --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --public-ip-address "" \
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.8

echo 'Done.'

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

echo 'Installing database...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-db -g WUS  \
    --script '@./src/database.sh'

echo 'Done.'

# CONFIGURE BACK-END

echo 'Creating VM for back-end...'

#BACK-END 1

az vm create --name petclinic-backend --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --vnet-name petclinic-vnet \
    --subnet petclinic-subnet --private-ip-address 10.0.0.5

echo 'Done.'

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

echo 'Installing project...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --script '@./src/backend.sh'

echo 'Done.'

#BACK-END 2


az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port 80 --priority 1014

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend \
    --port 443 --priority 1013

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend \
    --port 9967 --priority 1015

echo 'Done.'

echo 'Installing project...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --script '@./src/backend.sh'

echo 'Done.'

#BACK-END 3


az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port 80 --priority 1017

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port 443 --priority 1016

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port 9968 --priority 1018

echo 'Done.'

echo 'Installing project...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --script '@./src/backend.sh'

echo 'Done.'

# CONFIGURE NGINX

echo 'Creating VM for NGINX...'

az vm create --name petclinic-nginx --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --public-ip-sku Standard \
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.11

echo 'Done.'

echo 'Opening HTTP(S) ports for the VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-nginx  \
    --port 80 --priority 1011

az vm open-port \
    --resource-group WUS \
    --name petclinic-nginx  \
    --port 443 --priority 1010


echo 'Done.'

echo 'Installing project...'

echo 'Done.'

# CONFIGURE FRONT-END

echo 'Creating VM for front-end...'

az vm create --name petclinic-frontend --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --public-ip-sku Standard \
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.4

echo 'Done.'

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

echo 'Installing project...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-frontend -g WUS  \
    --script '@./src/frontend.sh' --parameters $(az vm show -g WUS -n petclinic-nginx -d --query [publicIps] --output tsv) \
    80


az vm run-command invoke  --command-id RunShellScript --name petclinic-nginx -g WUS  \
    --script '@./src/nginx.sh' --parameters $(az vm show -g WUS -n petclinic-backend -d --query [publicIps] --output tsv) \
    9966 \
    9967 \
    9968 \
    $(az vm show -g WUS -n petclinic-frontend -d --query [publicIps] --output tsv) \
    80 

echo 'Done.'



