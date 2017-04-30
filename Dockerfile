FROM alpine:3.5

ENV CONSUL_TEMPLATE_VERSION=0.18.2
ENV CONSUL_TEMPLATE_SHA256=6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c

RUN \
  apk add --no-cache --virtual .build-deps \
    curl \
    unzip \

  && apk add --no-cache \
    duplicity \
    rsync \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \

  && apk del .build-deps

ENV BACKUP_SOURCE=

ENV BACKUP_TARGET_USER=
ENV BACKUP_TARGET_HOST=
ENV BACKUP_TARGET_MODULE=
ENV BACKUP_TARGET_PATH=

ENV BACKUP_MODE=
ENV BACKUP_HOUR=0
ENV BACKUP_MINUTE=0
ENV BACKUP_IS_RANDOM_DELAY=

COPY rsyncd_password_file.template /root/rsyncd_password_file.template
COPY backup.sh /usr/local/bin/backup.sh
COPY start.sh /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
