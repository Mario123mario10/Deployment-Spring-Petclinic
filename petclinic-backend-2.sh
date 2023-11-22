# Aktualizacja i instalacja pakietów
#!/bin/sh

DB_ADDRESS=10.0.0.7
DB_USER=admin
DB_PASSWORD=admin
BACKEND_PORT=9962

cd ~/

sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-17-jdk -y

mkdir backend_2
cd backend_2

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

sed -i "s/=hsqldb/=mysql/g" ./src/main/resources/application.properties 
sed -i "s/localhost/$DB_ADDRESS/g" ./src/main/resources/application-mysql.properties
sed -i "s/pc/$DB_USER/g" ./src/main/resources/application-mysql.properties
sed -i "s/=petclinic/=$DB_PASSWORD/g" ./src/main/resources/application-mysql.properties
sed -i "s/9966/$BACKEND_PORT/g" ./src/main/resources/application.properties

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
./mvnw spring-boot:run &
