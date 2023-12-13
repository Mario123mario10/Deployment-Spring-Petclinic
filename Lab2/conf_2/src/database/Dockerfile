FROM debian:latest

WORKDIR /petclinic/db

COPY ./ ./

RUN chmod 755 ./database.sh

ENTRYPOINT ./database.sh 3306; sleep infinity;
