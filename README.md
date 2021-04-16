# docker-postfix

Forked from: https://github.com/juanluisbaptiste/docker-postfix

Changed the subnet restriction setting during the build of the container. In the build of juanluisbaptiste the internal networks 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 are added by default. The SMTP_NETWORKS variable is now the ONLY allowed relay host/subnet in this container.

* `SMTP_NETWORKS` Setting this will allow you to add additional, comma seperated, subnets to use the relay. Used like
    -e SMTP_NETWORKS='xxx.xxx.xxx.xxx/xx,xxx.xxx.xxx.xxx/xx'
    ### This is now the only allowed host/subnet to relay. The default 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 are not added anymore.


