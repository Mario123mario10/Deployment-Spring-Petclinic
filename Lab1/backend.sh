#!/bin/sh

# Create a VM for back-end

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
    --scripts 'git clone https://github.com/spring-petclinic/spring-petclinic-rest' \
    'cd spring-petclinic-rest/' \
    'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/' \
    './mvnw spring-boot:run &' \

echo 'Done.'