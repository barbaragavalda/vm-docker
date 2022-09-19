FROM httpd:alpine

ENV TZ Europe/Madrid

RUN apk update --update
RUN apk add -U tzdata
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime
#RUN echo "${TZ}" > etc/timezone