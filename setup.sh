#!/usr/bin/env bash
# This script setups dockerized Redash on Ubuntu 18.04.
# Author: Jayachandran Balachandran
set -eu

REDASH_BASE_PATH=$(pwd)

pre_work() {
    sudo brew install gnu-sed
    sudo docker build -t redash/redash:anz .
}

create_directories() {
    if [[ ! -e $REDASH_BASE_PATH ]]; then
        sudo mkdir -p $REDASH_BASE_PATH
        sudo chown $USER:$USER $REDASH_BASE_PATH
    fi

    if [[ ! -e $REDASH_BASE_PATH/postgres-data ]]; then
        rm -rf $REDASH_BASE_PATH/postgres-data
        mkdir $REDASH_BASE_PATH/postgres-data
    fi
}

create_config() {
    if [[ -e $REDASH_BASE_PATH/env ]]; then
        rm -f $REDASH_BASE_PATH/env
        touch $REDASH_BASE_PATH/env
    fi

    COOKIE_SECRET=$(pwgen -1s 32)
    POSTGRES_PASSWORD=$(pwgen -1s 32)
    REDASH_DATABASE_URL="postgresql://postgres:${POSTGRES_PASSWORD}@postgres/postgres"

    echo "PYTHONUNBUFFERED=0" >> $REDASH_BASE_PATH/env
    echo "REDASH_LOG_LEVEL=INFO" >> $REDASH_BASE_PATH/env
    echo "REDASH_REDIS_URL=redis://redis:6379/0" >> $REDASH_BASE_PATH/env
    echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> $REDASH_BASE_PATH/env
    echo "REDASH_COOKIE_SECRET=$COOKIE_SECRET" >> $REDASH_BASE_PATH/env
    echo "REDASH_DATABASE_URL=$REDASH_DATABASE_URL" >> $REDASH_BASE_PATH/env
}

setup_compose() {
    gsed -ri "s!BASEPATH!$REDASH_BASE_PATH!g" docker-compose.yml
    echo "export COMPOSE_PROJECT_NAME=redash" >> ~/.profile
    echo "export COMPOSE_FILE=$REDASH_BASE_PATH/docker-compose.yml" >> ~/.profile
    export COMPOSE_PROJECT_NAME=redash
    export COMPOSE_FILE=$REDASH_BASE_PATH/docker-compose.yml
    sudo docker-compose run --rm server create_db
    sudo docker-compose up -d
}

pre_work
create_directories
create_config
setup_compose
