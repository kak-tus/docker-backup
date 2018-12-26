FROM alpine:3.6

ENV \
  CONSUL_TEMPLATE_VERSION=0.18.5 \
  CONSUL_TEMPLATE_SHA256=b0cd6e821d6150c9a0166681072c12e906ed549ef4588f73ed58c9d834295cd2

RUN \
  apk add --no-cache --virtual .build-deps \
    curl \
    unzip \
  \
  && apk add --no-cache \
    busybox-suid \
    duplicity \
    openssh-client \
    rsync \
    su-exec \
    tzdata \
  \
  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  \
  && apk del .build-deps

ENV \
  BACKUP_SOURCE= \
  \
  BACKUP_TARGET_USER= \
  BACKUP_TARGET_HOST= \
  BACKUP_TARGET_MODULE= \
  BACKUP_TARGET_PATH= \
  BACKUP_TARGET_MODE=daemon \
  \
  BACKUP_MODE= \
  \
  BACKUP_HOUR=0 \
  BACKUP_MINUTE=0 \
  BACKUP_IS_RANDOM_DELAY= \
  \
  SET_CONTAINER_TIMEZONE=true \
  CONTAINER_TIMEZONE=Europe/Moscow \
  \
  BACKUP_USER_ROOT= \
  \
  BACKUP_DELETE_DAYS_OLDER=7 \
  \
  USER_UID=1000 \
  USER_GID=1000

COPY templates /etc/backup/templates
COPY backup.sh /usr/local/bin/backup.sh
COPY start.sh /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
