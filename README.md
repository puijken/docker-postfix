# docker-postfix

Forked from: https://github.com/juanluisbaptiste/docker-postfix

Changed the subnet restriction setting during the build of the container. In the build of juanluisbaptiste the internal networks 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 are added by default. The SMTP_NETWORKS variable is now the ONLY allowed relay host/subnet in this container.

* `SMTP_NETWORKS` Setting this will allow you to add additional, comma seperated, subnets to use the relay. Used like
    -e SMTP_NETWORKS='xxx.xxx.xxx.xxx/xx,xxx.xxx.xxx.xxx/xx'
    ### This is now the only allowed host/subnet to relay. The default 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 are not added anymore.

## Queue retry timing

Tightened from Postfix's stock defaults, since those are tuned for outages measured in
hours rather than a home relay's typical transient blip. Still overridable per deployment:

* `MINIMAL_BACKOFF_TIME` (default `300s`) -- shortest gap between delivery attempts for a
  deferred message.
* `MAXIMAL_BACKOFF_TIME` (default `900s`, was Postfix's own default of `4000s`/~67min) --
  longest gap between attempts. A shorter ceiling means a recovered network gets noticed
  within 15 minutes worst-case instead of over an hour.
* `QUEUE_RUN_DELAY` (default `300s`) -- how often the queue manager scans for messages
  that are due for a retry.

## Delivery delay notice

* `DELAY_WARNING_TIME` (default `1h`) -- how long a message can sit in the deferred queue
  before Postfix emails the original sender a one-time "still trying" notice. This is
  separate from (and much earlier than) the final bounce, which only fires after
  `maximal_queue_lifetime` (stock default `5d`) -- without this, a persistently failing
  message gives no signal at all until that final bounce. Sending the notice does not stop
  delivery from continuing to be retried normally. Whether the notice reaches anyone useful
  depends on the sending application setting a real envelope-from address.

