#!/bin/sh
cmd="$@"

if [ -z "$POSTGRES_USER" ]; then
    export POSTGRES_USER=postgres
fi

if [ -z "$POSTGRES_HOST" ]; then
    export POSTGRES_HOST=db
fi

export DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB

# make sure pg is ready to accept connections
until pg_isready -h $POSTGRES_HOST -U $POSTGRES_USER
do
  echo "Waiting for postgres"
  sleep 2;
done

exec $cmd