#!/usr/bin/env sh

delay=""
if [ -n "$BACKUP_IS_RANDOM_DELAY" ]; then
  delay="sleep ${RANDOM:0:2}m ;"
fi

( crontab -l ; echo "$BACKUP_MINUTE $BACKUP_HOUR * * * $delay /usr/local/bin/backup.sh" ) | crontab -

crond -f
child=$!

trap "kill $child" SIGTERM SIGINT
wait "$child"
