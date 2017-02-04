FROM alpine:3.5

ENV CONSUL_TEMPLATE_VERSION=0.18.0

COPY consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS /usr/local/bin/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS

RUN \
  apk add --update-cache curl unzip duplicity rsync \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && sha256sum -c consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS \

  && apk del curl unzip \
  && rm -rf /var/cache/apk/*

ENV BACKUP_SOURCE=

ENV BACKUP_TARGET_USER=
ENV BACKUP_TARGET_HOST=
ENV BACKUP_TARGET_MODULE=
ENV BACKUP_TARGET_PATH=
ENV BACKUP_TARGET_FULL_PATH=

COPY rsyncd_password_file.template /root/rsyncd_password_file.template
COPY backup /etc/periodic/daily/backup

CMD crond -f
