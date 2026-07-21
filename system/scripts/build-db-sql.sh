#!/bin/bash

source config.sh
source system.sh

setOriginalPath
setEnvironment

usage(){
    cat <<'USAGE'
Usage: sh build-db-sql.sh <slug>

  <slug>  project folder suffix, e.g. "tv-tracker" for tv-tracker-local

(Re)builds <project>/db.sql by concatenating freimguork-appacman's own
db.sql (always) with the db.sql of every vendorApp declared across all
sub-projects in config/projects.php (e.g. Webservice) that ships one -
vendors with no db.sql of their own are skipped silently.

Needs `composer install` to have already run in the project, since it
reads the schema files straight out of vendor/optisistem/*/db.sql. Run
this once right after composer install when scaffolding a new project,
and again any time a vendorApp is added to an existing project's
config/projects.php (then re-import the resulting db.sql by hand).
USAGE
}

slug=$1

if [ -z "$slug" ]; then
    usage
    cdOriginalPath
    exit 1
fi

hostNameAlias="${slug}-local"
projectPath="${STORAGE_SRC_PATH}/${hostNameAlias}"

if [ ! -d "$projectPath" ]; then
    echo "$projectPath not found"
    cdOriginalPath
    exit 1
fi

appacmanDbSql="$projectPath/vendor/optisistem/freimguork-appacman/db.sql"
if [ ! -f "$appacmanDbSql" ]; then
    echo "$appacmanDbSql not found - run composer install in the project first"
    cdOriginalPath
    exit 1
fi

vendorApps=$(docker exec php php -r "
    include '/var/www/html/${hostNameAlias}/config/projects.php';
    \$apps = array();
    foreach (\$config as \$project) {
        if (!empty(\$project['vendorApps'])) {
            foreach (\$project['vendorApps'] as \$app) {
                \$apps[\$app] = true;
            }
        }
    }
    echo implode(' ', array_keys(\$apps));
")
if [ $? -ne 0 ]; then
    echo "could not read ${hostNameAlias}/config/projects.php via the php container - is it running?"
    cdOriginalPath
    exit 1
fi

echo "==> building db.sql (appacman${vendorApps:+ + }${vendorApps})"
cat "$appacmanDbSql" > "$projectPath/db.sql"

for app in $vendorApps; do
    vendorSlug=$(echo "$app" | tr '[:upper:]' '[:lower:]')
    vendorDbSql="$projectPath/vendor/optisistem/freimguork-${vendorSlug}/db.sql"
    if [ -f "$vendorDbSql" ]; then
        echo "" >> "$projectPath/db.sql"
        cat "$vendorDbSql" >> "$projectPath/db.sql"
    fi
done

cdOriginalPath

echo "Done. ${projectPath}/db.sql rebuilt."
