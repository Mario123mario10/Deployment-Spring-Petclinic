# Aktualizacja i instalacja pakietów
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install openjdk-17-jdk maven -y  # Można zmienić wersję Javy w zależności od potrzeb

# Klonowanie repozytorium
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

# Konfiguracja połączenia z bazą danych
# Tutaj trzeba dostosować ustawienia do własnych potrzeb, np. plik application.properties

# Kompilacja i uruchomienie aplikacji
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/ 
./mvnw spring-boot:run & 
