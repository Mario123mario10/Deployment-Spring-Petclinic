FROM debian:latest

WORKDIR /petclinic/backend

COPY ./ ./

RUN chmod 755 ./backend.sh

ENTRYPOINT ./backend.sh 3000 ${DB_MASTER_IP} ${DB_MASTER_PORT} ${DB_SLAVE_IP} ${DB_SLAVE_PORT}; sleep infinity;
