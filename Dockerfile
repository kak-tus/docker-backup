FROM alpine:3.5

ENV CONSUL_TEMPLATE_VERSION=0.18.0
ENV CONSUL_TEMPLATE_SHA256=f7adf1f879389e7f4e881d63ef3b84bce5bc6e073eb7a64940785d32c997bc4b

RUN \
  apk add --no-cache --virtual .build-deps curl unzip \

  && apk add --no-cache duplicity rsync \

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

COPY rsyncd_password_file.template /root/rsyncd_password_file.template
COPY backup /etc/periodic/daily/backup

CMD [ "crond", "-f" ]
