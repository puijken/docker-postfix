#Dockerfile for a Postfix email relay service
FROM alpine:3.24
LABEL org.opencontainers.image.authors="puijken"

RUN apk add --no-cache bash gawk cyrus-sasl cyrus-sasl-login cyrus-sasl-crammd5 mailx \
    postfix && \
    sed -i -e 's/inet_interfaces = localhost/inet_interfaces = all/g' /etc/postfix/main.cf

COPY run.sh /
RUN chmod +x /run.sh
RUN newaliases

EXPOSE 25
CMD ["/run.sh"]
