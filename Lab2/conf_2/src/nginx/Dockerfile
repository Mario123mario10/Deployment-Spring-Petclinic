FROM debian:latest

WORKDIR /petclinic/nginx

COPY ./ ./

RUN chmod 755 ./nginx.sh

ENTRYPOINT ./nginx.sh ${BACKEND_IP} ${BACKEND_PORT_1} ${BACKEND_PORT_2} ${BACKEND_PORT_3} 3500; sleep infinity;
