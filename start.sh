#!/usr/bin/env sh

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo "$CONTAINER_TIMEZONE" > /etc/timezone \
    && ln -sf "/usr/share/zoneinfo/$CONTAINER_TIMEZONE" /etc/localtime
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

delay=""
if [ -n "$BACKUP_IS_RANDOM_DELAY" ]; then
  delay="sleep ${RANDOM:0:2}m ;"
fi

if [ -z "$BACKUP_USER_ROOT" ]; then
  deluser user 2>/dev/null
  delgroup user 2>/dev/null
  addgroup -g $USER_GID user
  adduser -h /home/user -G user -D -u $USER_UID user

  chown -R user:user /etc/backup

  echo "$BACKUP_MINUTE $BACKUP_HOUR * * * $delay /usr/local/bin/backup.sh" | su-exec user crontab -
else
  echo "$BACKUP_MINUTE $BACKUP_HOUR * * * $delay /usr/local/bin/backup.sh" | crontab -
fi

crond -f &
child=$!

trap "kill $child" SIGTERM SIGINT
wait "$child"
