FROM ubuntu:latest

ARG HOSTNAME
ARG MAIL_SERVER_HOST
ARG MAIL_SERVER_PORT
ARG MAIL_SERVER_DOMAIN
ARG MAIL_SERVER_USER
ARG MAIL_SERVER_PASSWORD
ARG INTERNAL_NETWORK=127.0.0.1/32

EXPOSE 25/tcp
EXPOSE 465/tcp
EXPOSE 587/tcp

RUN apt-get update && \
  apt-get install -y nano telnet net-tools && \
  apt-get install -y postfix mailutils sasl2-bin libsasl2-modules

COPY assets/ /

RUN sh -c 'echo "${HOSTNAME}" >> /etc/mailname' && \
  postconf mynetworks=${INTERNAL_NETWORK} && \
  sh -c 'echo "[${MAIL_SERVER_HOST}]:${MAIL_SERVER_PORT} ${MAIL_SERVER_USER}@${MAIL_SERVER_DOMAIN}:${MAIL_SERVER_PASSWORD}" >> /etc/postfix/sasl_passwd' && \
  postmap /etc/postfix/sasl_passwd && \
  chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db && \
  mkdir -p /var/log/postfix && touch /var/log/postfix/postfix.log && \
  echo "${MAIL_SERVER_PASSWORD}" | saslpasswd2 -c -p -u "${MAIL_SERVER_DOMAIN}" "${MAIL_SERVER_USER}" && \
  cp /etc/sasldb2 /var/spool/postfix/etc/ && \
  chown postfix:sasl /var/spool/postfix/etc/sasldb2 && \
  chmod 660 /var/spool/postfix/etc/sasldb2

CMD service postfix restart && tail -f /dev/null
