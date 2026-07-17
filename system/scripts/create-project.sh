#!/bin/bash

source config.sh
source system.sh

setOriginalPath
setEnvironment

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SKELETON_PATH="${STORAGE_SRC_PATH}/freimguork-skeleton"

usage(){
    cat <<'USAGE'
Usage: sh create-project.sh <slug> <prod-domain> [project-name] [description]

  <slug>          lowercase-hyphenated, e.g. "tv-tracker". Used for the local
                  host (<slug>.local), the project folder (<slug>-local),
                  the DB name and the composer package name.
  <prod-domain>   production domain, e.g. "tvtracker.com"
  [project-name]  human-readable name (default: Title Case of <slug>)
  [description]   short description (default: empty)

Scaffolds a new core+Appacman project from freimguork-skeleton: creates the
vhost/host entry (via host.sh), copies the skeleton, fills in every
placeholder, generates encryption secrets, creates the database (using the
shared mariadb credentials documented in the VM's own README.md), imports
the base Appacman schema and runs composer install.

Creating the first admin user is left as a manual step (see "First admin
user" in the new project's own README.md) since it needs a real password
you choose, encrypted with that project's own secret.
USAGE
}

# shared VM-wide DB user, documented in ../../README.md "3.1.1. Database" -
# matches docker-compose.yml's php service MYSQL_USER/MYSQL_PASSWORD env
DB_ADMIN_USER="optisistem"
DB_ADMIN_PASSWORD="rtZYS9wJ7HWWNK"

slug=$1
prodDomain=$2
projectName=${3:-$(echo "$slug" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')}
description=${4:-}

if [ -z "$slug" ] || [ -z "$prodDomain" ]; then
    usage
    cdOriginalPath
    exit 1
fi

if ! echo "$slug" | grep -qE '^[a-z][a-z0-9-]*$'; then
    echo "slug must be lowercase letters, digits and hyphens only (got: $slug)"
    cdOriginalPath
    exit 1
fi

hostName="${slug}.local"
hostNameAlias="${slug}-local"
projectPath="${STORAGE_SRC_PATH}/${hostNameAlias}"
dbName="$slug"

if [ -d "$projectPath" ]; then
    echo "$projectPath already exists - aborting so nothing gets overwritten"
    cdOriginalPath
    exit 1
fi

if [ ! -d "$SKELETON_PATH" ]; then
    echo "Skeleton not found at $SKELETON_PATH"
    cdOriginalPath
    exit 1
fi

dbExists=$(docker exec -i -e MYSQL_PWD="${DB_ADMIN_PASSWORD}" mariadb mariadb -u"${DB_ADMIN_USER}" -N -e "SHOW DATABASES LIKE '${dbName}';")
if [ -n "$dbExists" ]; then
    echo "database '${dbName}' already exists - aborting so nothing gets reused by accident"
    cdOriginalPath
    exit 1
fi

echo "==> creating host $hostName"
sh "$SCRIPT_DIR/host.sh" create "$hostName"

echo "==> copying skeleton into $projectPath"
rsync -a --exclude='.git' "$SKELETON_PATH/" "$projectPath/"
rm -f "$projectPath/web/index.html"

echo "==> generating encryption secrets"
secretDev=$(docker exec php php -r 'echo bin2hex(random_bytes(32));')
secretProd=$(docker exec php php -r 'echo bin2hex(random_bytes(32));')

if [ -z "$secretDev" ] || [ -z "$secretProd" ]; then
    echo "could not generate secrets via the php container - is it running?"
    cdOriginalPath
    exit 1
fi

cd "$projectPath" || exit 1
git init -q

echo "==> fetching latest jQuery"
# code.jquery.com's own "jquery-latest.min.js" alias is a known trap - it has
# been frozen at v1.11.1 for years. Ask npm for the real latest version
# instead, then download that exact versioned build.
jqueryVersion=$(curl -fsSL --max-time 10 https://registry.npmjs.org/jquery/latest 2>/dev/null | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -n "$jqueryVersion" ] && curl -fsSL --max-time 15 "https://code.jquery.com/jquery-${jqueryVersion}.min.js" -o "web/static/js/jquery-${jqueryVersion}.min.js.tmp"; then
    rm -f web/static/js/jquery-*.min.js
    mv "web/static/js/jquery-${jqueryVersion}.min.js.tmp" "web/static/js/jquery-${jqueryVersion}.min.js"
    echo "    using jQuery ${jqueryVersion}"
else
    rm -f web/static/js/jquery-*.min.js.tmp
    echo "    could not fetch latest jQuery - keeping the version bundled in the skeleton"
fi

echo "==> filling placeholders"
for f in composer.json config/dev/base_domain.php config/prod/base_domain.php src/Web/Controller/Home.php db.sql locale/en_GB/LC_MESSAGES/messenges.po; do
    sed -i '' \
        -e "s#{{project-slug}}#${slug}#g" \
        -e "s#{{project name}}#${projectName}#g" \
        -e "s#{{project description}}#${description}#g" \
        -e "s#{{project-domain}}#${prodDomain}#g" \
        "$f"
done

echo "==> writing real config files"
cp config/dev/db.php.dist config/dev/db.php
cp config/prod/db.php.dist config/prod/db.php
cp config/dev/keys.php.dist config/dev/keys.php
cp config/prod/keys.php.dist config/prod/keys.php

for f in config/dev/db.php config/prod/db.php; do
    sed -i '' \
        -e "s/<db-user>/${DB_ADMIN_USER}/g" \
        -e "s/<db-password>/${DB_ADMIN_PASSWORD}/g" \
        -e "s/<db-name>/${dbName}/g" \
        "$f"
done
sed -i '' "s/<64 hex chars>/${secretDev}/g" config/dev/keys.php
sed -i '' "s/<64 hex chars>/${secretProd}/g" config/prod/keys.php

echo "==> creating database"
docker exec -i -e MYSQL_PWD="${DB_ADMIN_PASSWORD}" mariadb mariadb -u"${DB_ADMIN_USER}" -e "CREATE DATABASE \`${dbName}\`;"
if [ $? -ne 0 ]; then
    echo "database creation failed - finish this step manually (see README.md)"
    cdOriginalPath
    exit 1
fi

echo "==> importing db.sql"
docker exec -i -e MYSQL_PWD="${DB_ADMIN_PASSWORD}" mariadb mariadb -u"${DB_ADMIN_USER}" "${dbName}" < db.sql

echo "==> composer install (also publishes Appacman/AdminLTE assets into web/)"
docker exec php sh -c "cd /var/www/html/${hostNameAlias} && composer install"

cdOriginalPath

cat <<SUMMARY

Done. ${projectName} is ready at:
  http://${hostName}/          (public site)
  http://${hostName}/wallaby/  (Appacman admin - no user yet)

DB: name=${dbName} (uses the shared VM DB user, already written into
config/{dev,prod}/db.php)

Next manual step: create the first admin user - see "First admin user" in
${projectPath}/README.md.
SUMMARY
