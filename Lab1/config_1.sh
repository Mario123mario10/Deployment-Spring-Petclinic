#!/bin/sh

FRONTEND_PORT="$1"
BACKEND_PORT="$2"
DB_PORT="$3"

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
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.6

echo 'Done.'

echo 'Opening ports for the database VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-db  \
    --port $DB_PORT --priority 1010

echo 'Done.'

echo 'Installing database...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-db -g WUS  \
    --script '@./src/database.sh' --parameters $DB_PORT

echo 'Done.'

# CONFIGURE BACK-END

echo 'Creating VM for back-end...'

az vm create --name petclinic-backend --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --vnet-name petclinic-vnet \
    --subnet petclinic-subnet --private-ip-address 10.0.0.5

echo 'Done.'

echo 'Opening ports for the backend VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port $BACKEND_PORT --priority 1012

echo 'Done.'

echo 'Installing project...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --script '@./src/backend.sh' --parameters $BACKEND_PORT $DB_PORT

echo 'Done.'

# CONFIGURE FRONT-END

echo 'Creating VM for front-end...'

az vm create --name petclinic-frontend --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --public-ip-sku Standard \
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.4

echo 'Done.'

echo 'Opening ports for the frontend VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-frontend  \
    --port $FRONTEND_PORT --priority 1011

echo 'Done.'

echo 'Installing project...'

az vm run-command invoke  --command-id RunShellScript --name petclinic-frontend -g WUS  \
    --script '@./src/frontend.sh' --parameters $(az vm show -g WUS -n petclinic-backend -d --query [publicIps] --output tsv) $FRONTEND_PORT $BACKEND_PORT

echo 'Done.'
