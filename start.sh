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

( crontab -l ; echo "$BACKUP_MINUTE $BACKUP_HOUR * * * $delay /usr/local/bin/backup.sh" ) | crontab -

crond -f
child=$!

trap "kill $child" SIGTERM SIGINT
wait "$child"
