#!/bin/sh

MASTER_IP="10.0.0.8"  # Adres IP bazy danych master
DB_USER="admin"
DB_PASSWORD="admin"
MASTER_LOG_FILE="mysql-bin.000001"  # Pobierz aktualną nazwę pliku z mastera
MASTER_LOG_POS=107  # Pobierz aktualną pozycję z mastera

sudo apt update
sudo apt upgrade -y
sudo apt install mysql-server -y

# Konfiguracja MySQL
CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
sudo sed -i "s/127.0.0.1/0.0.0.0/g" $CONFIG_FILE
sudo sed -i "s/.*server-id.*/server-id = 2/" $CONFIG_FILE  # Unikalne ID dla slave
sudo sed -i "s/.*log_bin.*/log_bin = \\/var\\/log\\/mysql\\/mysql-bin.log/" $CONFIG_FILE
sudo service mysql restart

# Ustawianie slave
cat << EOF | sudo mysql -u root
CHANGE MASTER TO
    MASTER_HOST='$MASTER_IP',
    MASTER_USER='$DB_USER',
    MASTER_PASSWORD='$DB_PASSWORD',
    MASTER_LOG_FILE='$MASTER_LOG_FILE',
    MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
EOF

# Sprawdzenie statusu replikacji
sudo mysql -u root -e "SHOW SLAVE STATUS \G"