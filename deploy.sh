az mysql flexible-server create \
    --resource-group WUS3 \
    --name petclinic-db \
    --database-name db1 \
    --admin-user azureuser \
    --admin-password '<admin-password>'



#!/bin/sh

# Ustawienia ogólne
resourceGroup="WUS"
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

# Tworzenie maszyn wirtualnych dla bazy danych master i slave
create_vm "petclinic-db" "10.0.0.6"

# Tworzenie maszyn wirtualnych dla backendu
create_vm "petclinic-backend-1" "10.0.0.5"
create_vm "petclinic-backend-2" "10.0.0.8"
create_vm "petclinic-backend-2" "10.0.0.3"

# Tworzenie maszyny wirtualnej dla NGINX Load Balancer
create_vm "petclinic-nginx-lb" "10.0.0.9"

# Tworzenie maszyny wirtualnej dla frontendu
create_vm "petclinic-frontend" "10.0.0.4"

# Konfiguracja bazy danych master i slave

az vm run-command invoke \
                    --resource-group $resourceGroup \
                    --name "petclinic-db" \
                    --command-id RunShellScript \
                    --scripts "@./database" 


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

                    az vm run-command invoke \
                    --resource-group $resourceGroup \
                    --name "petclinic-backend-3" \
                    --command-id RunShellScript \
                    --scripts "@./petclinic-backend-3.sh"		

# Konfiguracja NGINX Load Balancer

az vm run-command invoke \
				--resource-group $resourceGroup \
				--name "petclinic-nginx-lb" \
				--command-id RunShellScript \
				--scripts "@./nginx.sh"	


# Konfiguracja frontendu Angular

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
