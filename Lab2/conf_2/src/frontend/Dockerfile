FROM debian:latest

WORKDIR /petclinic/frontend

COPY ./ ./

RUN chmod 755 ./frontend.sh

ENTRYPOINT ./frontend.sh 80 ${API_IP} ${API_PORT}; sleep infinity;
