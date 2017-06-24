#!/usr/bin/env sh

consul-template -once \
  -template "/etc/rsyncd_password_file.template:/home/user/rsyncd_password_file"
chmod 0600 /home/user/rsyncd_password_file

# create target path
mkdir -p "/tmp${BACKUP_TARGET_PATH}"
touch "/tmp${BACKUP_TARGET_PATH}/.tmp"
rsync -r \
  --password-file=/home/user/rsyncd_password_file \
  "/tmp${BACKUP_TARGET_PATH}" \
  ${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::${BACKUP_TARGET_MODULE}/
rm -rf "/tmp${BACKUP_TARGET_PATH}"

if [ "$BACKUP_MODE" = "sync" ]; then
  rsync -r \
    --password-file=/home/user/rsyncd_password_file \
    ${BACKUP_SOURCE}/ \
    ${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/ \
  && ( find "$BACKUP_SOURCE" -mtime +7 -type f | xargs -I QQ rm QQ )
else
  ionice -c 3 \
  duplicity --volsize 256 --no-encryption --full-if-older-than="1M" \
    --rsync-options="--password-file=/home/user/rsyncd_password_file" \
    $BACKUP_SOURCE \
    rsync://${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::/${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/
fi
