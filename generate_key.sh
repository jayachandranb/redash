#!/bin/sh

FLAG="/var/log/generate_secrets.log"
if [ ! -f $FLAG ]; then
  COOKIE_SECRET=$(pwgen -1s 32)
  POSTGRES_PASSWORD=$(pwgen -1s 32)
  REDASH_DATABASE_URL="postgresql:\/\/postgres:$POSTGRES_PASSWORD@postgres\/postgres"

  gsed -i "s/REDASH_COOKIE_SECRET=.*/REDASH_COOKIE_SECRET=$COOKIE_SECRET/g" /opt/redash/env
  gsed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$POSTGRES_PASSWORD/g" /opt/redash/env
  gsed -i "s/REDASH_DATABASE_URL=.*/REDASH_DATABASE_URL=$REDASH_DATABASE_URL/g" /opt/redash/env

  #the next line creates an empty file so it won't run the next boot
  echo "$(date) Updated secrets." >> $FLAG
else
  echo "Secrets already set, skipping."
fi

exit 0
