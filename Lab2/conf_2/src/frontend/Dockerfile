FROM debian:latest

WORKDIR /petclinic/frontend

COPY ./ ./

RUN chmod 755 ./frontend.sh

ENTRYPOINT ./frontend.sh ${FRONTEND_PORT} ${API_IP} ${API_PORT}; sleep infinity;
