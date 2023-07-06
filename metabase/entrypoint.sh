#!/bin/bash

# extract the protocol
proto="$(echo $METABASE_DATABASE_URL | grep '://' | sed -e's,^\(.*://\).*,\1,g')"

# remove the protocol
url="$(echo $METABASE_DATABASE_URL | sed -e s,$proto,,g)"

# extract the user and password (if any)
userpass="$(echo $url | grep @ | cut -d@ -f1)"
MB_DB_PASS="$(echo $userpass | grep : | cut -d: -f2)"
if [ -n "$MB_DB_PASS" ]; then
    MB_DB_USER="$(echo $userpass | grep : | cut -d: -f1)"
else
    MB_DB_USER=$userpass
fi

# extract the host, port, and database type
hostport="$(echo $url | sed -e s,$userpass@,,g | cut -d/ -f1)"
port="$(echo $hostport | grep : | cut -d: -f2)"
if [ -n "$port" ]; then
    MB_DB_HOST="$(echo $hostport | grep : | cut -d: -f1)"
else
    MB_DB_HOST=$hostport
    if [ "$proto" = "postgresql://" ]; then
        MB_DB_PORT=5432
        MB_DB_TYPE=postgres
    elif [ "$proto" = "mysql://" ]; then
        MB_DB_PORT=3306
        MB_DB_TYPE=mysql
    else
        echo "Unknown database type: $proto" >&2
        exit 1
    fi
fi

# extract the path (if any)
MB_DB_DBNAME="$(echo $url | grep / | cut -d/ -f2-)"

# export all variables
export MB_DB_TYPE
export MB_DB_DBNAME
export MB_DB_PORT
export MB_DB_USER
export MB_DB_PASS
export MB_DB_HOST

exec /app/run_metabase.sh "$@"
