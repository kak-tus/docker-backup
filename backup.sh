#!/usr/bin/env sh

if [ "$BACKUP_TARGET_MODE" = "daemon" ]; then
  file="rsyncd_password_file"
else
  file="rsync_ssh_key"
fi

consul-template -once \
  -template "/etc/backup/templates/$file.template:/etc/backup/$file"
chmod 0600 "/etc/backup/$file"

# create target path
mkdir -p "/tmp${BACKUP_TARGET_PATH}"
touch "/tmp${BACKUP_TARGET_PATH}/.tmp"

if [ "$BACKUP_TARGET_MODE" = "daemon" ]; then
  rsync_args="--password-file=/etc/backup/rsyncd_password_file"
  rsync_tmp_target="${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::${BACKUP_TARGET_MODULE}/"
  rsync_tmp_src="/tmp${BACKUP_TARGET_PATH}"
  rsync_target="${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/"

  dupl_args="--password-file=/etc/backup/rsyncd_password_file"
  dupl_target="${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}::/${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/"
else
  rsync_args="-e \"ssh -i /etc/backup/rsync_ssh_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no\""
  rsync_tmp_target="${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}:${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/"
  rsync_tmp_src="/tmp${BACKUP_TARGET_PATH}/"
  rsync_target="${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}:${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/"

  # We need quote and quote and quote - unusable sh
  dupl_args="-e \\\"ssh -i /etc/backup/rsync_ssh_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no\\\""
  dupl_target="${BACKUP_TARGET_USER}@${BACKUP_TARGET_HOST}/${BACKUP_TARGET_MODULE}${BACKUP_TARGET_PATH}/"
fi

eval "rsync -r $rsync_args $rsync_tmp_src $rsync_tmp_target"

rm -rf "/tmp${BACKUP_TARGET_PATH}"

if [ "$BACKUP_MODE" = "sync" ]; then
  eval "rsync -r $rsync_args ${BACKUP_SOURCE}/ $rsync_target && ( find \"$BACKUP_SOURCE\" -mtime +$BACKUP_DELETE_DAYS_OLDER -type f | xargs -I QQ rm QQ )"
else
  eval "ionice -c 3 duplicity --volsize 256 --no-encryption --full-if-older-than=\"1M\" --rsync-options=\"$dupl_args\" ${BACKUP_SOURCE} rsync://$dupl_target"
fi
