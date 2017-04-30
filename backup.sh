#!/usr/bin/env sh

consul-template -once \
  -template "/root/rsyncd_password_file.template:/etc/rsyncd_password_file"
chmod 0600 /etc/rsyncd_password_file

# create target path
mkdir -p "/tmp${BACKUP_TARGET_PATH}"
touch "/tmp${BACKUP_TARGET_PATH}/.tmp"
rsync -r \
  --password-file=/etc/rsyncd_password_file \
  "/tmp${BACKUP_TARGET_PATH}" \
  ${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::${BACKUP_TARGET_MODULE}/
rm -rf "/tmp${BACKUP_TARGET_PATH}"

if [ "$BACKUP_MODE" = "sync" ]; then
  rsync -r \
    --password-file=/etc/rsyncd_password_file \
    ${BACKUP_SOURCE}/ \
    ${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/
else
  duplicity --volsize 256 --no-encryption --full-if-older-than="1M" \
    --rsync-options="--password-file=/etc/rsyncd_password_file" \
    $BACKUP_SOURCE \
    rsync://${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::/${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/
fi
