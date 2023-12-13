#!/bin/sh

FRONTEND_PORT=80
BACKEND_PORT_1=5050
BACKEND_PORT_2=6060
BACKEND_PORT_3=8080
DB_PORT=3306
NGINX_PORT=5000

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
    --image Ubuntu2204 \
    --vnet-name petclinic-vnet --subnet petclinic-subnet --private-ip-address 10.0.0.6

echo 'Done.'

echo 'Opening ports for the database VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-db  \
    --port $DB_PORT --priority 1010

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
    --port $BACKEND_PORT_1 --priority 1012

az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port $BACKEND_PORT_2 --priority 1013
    
az vm open-port \
    --resource-group WUS \
    --name petclinic-backend  \
    --port $BACKEND_PORT_3 --priority 1014

echo 'Done.'

# CONFIGURE NGINX

echo 'Creating VM for nginx...'

az vm create --name petclinic-nginx --resource-group WUS \
    --admin-username azureuser --generate-ssh-keys \
    --image Ubuntu2204 --vnet-name petclinic-vnet \
    --subnet petclinic-subnet --private-ip-address 10.0.0.5

echo 'Done.'

echo 'Opening ports for the nginx VM...'

az vm open-port \
    --resource-group WUS \
    --name petclinic-nginx  \
    --port $NGINX_PORT --priority 1012

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
    --port 80 --priority 1011

echo 'Done.'

FRONTEND_HOST=$(az vm show -g WUS -n petclinic-frontend -d --query [publicIps] --output tsv)
BACKEND_HOST=$(az vm show -g WUS -n petclinic-backend -d --query [publicIps] --output tsv)
DB_HOST=$(az vm show -g WUS -n petclinic-db -d --query [publicIps] --output tsv)
NGINX_HOST=$(az vm show -g WUS -n petclinic-nginx -d --query [publicIps] --output tsv)

echo 'Installing Ansible...'

pip install ansible

cat inventory.yaml > inventory_params.yaml

sed -i "s/FRONTEND_HOST/$FRONTEND_HOST/g" inventory_params.yaml
sed -i "s/BACKEND_HOST/$BACKEND_HOST/g" inventory_params.yaml
sed -i "s/DB_HOST/$DB_HOST/g" inventory_params.yaml
sed -i "s/NGINX_HOST/$NGINX_HOST/g" inventory_params.yaml

sed -i "s/FRONTEND_PORT/$FRONTEND_PORT/g" inventory_params.yaml
sed -i "s/BACKEND_PORT/$BACKEND_PORT/g" inventory_params.yaml
sed -i "s/DB_PORT/$DB_PORT/g" inventory_params.yaml
sed -i "s/NGINX_PORT/$NGINX_PORT/g" inventory_params.yaml

ansible-playbook setup.yaml -i inventory_params.yaml
ansible-playbook config_2.yaml -i inventory_params.yaml