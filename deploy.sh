#!/bin/sh

# Ustawienia ogólne
resourceGroup="WUS3"
vnetName="petclinic-vnet"
subnetName="petclinic-subnet"
location="uksouth"

# Tworzenie resource group
echo 'Creating resource group for the infrastructure...'
az group create -l $location -n $resourceGroup
echo 'Done'

# Tworzenie sieci wirtualnej i podsieci
echo 'Creating virtual network and subnet...'
az network vnet create \
    --name $vnetName \
    --resource-group $resourceGroup \
    --address-prefix 10.0.0.0/16 \
    --subnet-name $subnetName \
    --subnet-prefixes 10.0.0.0/24
echo 'Done.'

# Funkcja do tworzenia maszyn wirtualnych
create_vm() {
    vmName=$1
    privateIpAddress=$2

    echo "Creating VM: $vmName with IP: $privateIpAddress..."
    az vm create --name $vmName --resource-group $resourceGroup \
        --admin-username azureuser --generate-ssh-keys \
        --image Ubuntu2204 --public-ip-address "" \
        --vnet-name $vnetName --subnet $subnetName \
        --private-ip-address $privateIpAddress
    echo 'Done.'
}

create_vm_public() {
    vmName=$1
    privateIpAddress=$2
    
    echo "Creating VM: $vmName with IP: $privateIpAddress..."
    az vm create --name $vmName --resource-group $resourceGroup \
        --admin-username azureuser --generate-ssh-keys \
        --image Ubuntu2204 --public-ip-sku Standard \
        --vnet-name $vnetName --subnet $subnetName \
        --private-ip-address $privateIpAddress
    echo 'Done.'
}


# Tworzenie maszyny wirtualnej dla frontendu
create_vm_public "petclinic-frontend" "10.0.0.4"

# Tworzenie maszyny wirtualnej dla NGINX Load Balancer
create_vm_public "petclinic-nginx" "10.0.0.5"

# Tworzenie maszyn wirtualnych dla backendu
create_vm "petclinic-backend-1" "10.0.0.6"
create_vm "petclinic-backend-2" "10.0.0.7"

# Tworzenie maszyn wirtualnych dla bazy danych master i slave
create_vm "petclinic-db-master" "10.0.0.8"
create_vm "petclinic-db-slave" "10.0.0.9"

# Otwórz porty dla bazy danych master
az vm open-port --resource-group $resourceGroup --name petclinic-db-master --port 3306 --priority 1001

# Otwórz porty dla bazy danych slave
az vm open-port --resource-group $resourceGroup --name petclinic-db-slave --port 3306 --priority 1002

# Otwórz porty dla serwerów backendowych
az vm open-port --resource-group $resourceGroup --name petclinic-backend-1 --port 9966 --priority 1011
az vm open-port --resource-group $resourceGroup --name petclinic-backend-2 --port 9966 --priority 1012

# Otwórz porty dla NGINX Load Balancer
az vm open-port --resource-group $resourceGroup --name petclinic-nginx --port 80 --priority 1013
az vm open-port --resource-group $resourceGroup --name petclinic-nginx --port 443 --priority 1014

# Otwórz porty dla frontendu Angular
az vm open-port --resource-group $resourceGroup --name petclinic-frontend --port 80 --priority 1015
az vm open-port --resource-group $resourceGroup --name petclinic-frontend --port 443 --priority 1016
# Konfiguracja bazy danych master i slave

az vm run-command invoke \
                    --resource-group $resourceGroup \
                    --name "petclinic-db-master" \
                    --command-id RunShellScript \
                    --scripts "@./sql-master.sh" 


az vm run-command invoke \
                    --resource-group $resourceGroup \
                    --name "petclinic-db-slave" \
                    --command-id RunShellScript \
                    --scripts "@./sql-slave.sh" 

# Konfiguracja backendu
# (dodaj tu odpowiednie skrypty konfiguracyjne dla Spring Boot)

az vm run-command invoke \
                    --resource-group $resourceGroup \
                    --name "petclinic-backend-1" \
                    --command-id RunShellScript \
                    --scripts "@./petclinic-backend-1.sh"
					

az vm run-command invoke \
                    --resource-group $resourceGroup \
                    --name "petclinic-backend-2" \
                    --command-id RunShellScript \
                    --scripts "@./petclinic-backend-2.sh"			

# Konfiguracja NGINX Load Balancer

az vm run-command invoke \
				--resource-group $resourceGroup \
				--name "petclinic-nginx" \
				--command-id RunShellScript \
				--scripts "@./nginx.sh"	


# Konfiguracja frontendu Angular         

az vm run-command invoke  \
                --command-id RunShellScript \
                --name petclinic-frontend -g $resourceGroup  \
                --script '@./src/frontend.sh' \
                --parameters $(az vm show -g $resourceGroup -n petclinic-nginx -d --query [publicIps] --output tsv)

echo 'Done.'