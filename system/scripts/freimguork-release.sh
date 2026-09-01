#!/bin/sh

source config.sh
source system.sh

setOriginalPath
setEnvironment

usage(){
    cat <<'USAGE'
Usage: sh freimguork-release.sh <repo-slug> <version> [message]

  <repo-slug>  one of: freimguork-core, freimguork-webservice, freimguork-appacman
  <version>    tag name, e.g. v2.2 (bare vX.Y, matching this family's convention)
  [message]    annotated tag message (default: prompts interactively, end with Ctrl-D)

Runs that repo's full test suite (+ PHPStan and the sibling-constraint check, where
configured) inside the php container. Only if everything passes does it create an
annotated tag and push it to origin (Bitbucket). Refuses to run against a dirty working
tree, a local master out of sync with origin/master, or a tag name that already exists -
and never moves an existing tag: cutting a new one is always the answer to "the last tag
had a bug", the same way v2.0 -> v2.1 was handled for freimguork-core.
USAGE
}

repoSlug=$1
version=$2
message=$3

case "$repoSlug" in
    freimguork-core|freimguork-webservice|freimguork-appacman) ;;
    *)
        usage
        exit 1
    ;;
esac

if [ -z "$version" ]; then
    usage
    exit 1
fi

repoPath="${STORAGE_SRC_PATH}/${repoSlug}"

if [ ! -d "$repoPath" ]; then
    echo "No such repo checkout: $repoPath" >&2
    exit 1
fi

cd "$repoPath" || exit 1

if [ -n "$(git status --short)" ]; then
    echo "Working tree not clean - commit or stash first." >&2
    exit 1
fi

git fetch origin master --quiet
if [ "$(git rev-parse master)" != "$(git rev-parse origin/master)" ]; then
    echo "Local master is not in sync with origin/master - pull or push first." >&2
    exit 1
fi

if git rev-parse "$version" >/dev/null 2>&1; then
    echo "Tag $version already exists - cut a new version instead of reusing this one." >&2
    exit 1
fi

echo "Installing dependencies for $repoSlug..."
docker exec php sh -c "cd /var/www/html/$repoSlug && composer install --no-interaction" || {
    echo "composer install failed, aborting." >&2
    exit 1
}

scripts=$(docker exec php sh -c "cd /var/www/html/$repoSlug && composer run-script --list" 2>/dev/null)

echo "Running tests for $repoSlug..."
docker exec php sh -c "cd /var/www/html/$repoSlug && composer test" || {
    echo "Tests failed, aborting." >&2
    exit 1
}

if echo "$scripts" | grep -q phpstan; then
    echo "Running PHPStan for $repoSlug..."
    docker exec php sh -c "cd /var/www/html/$repoSlug && composer phpstan" || {
        echo "PHPStan failed, aborting." >&2
        exit 1
    }
fi

if echo "$scripts" | grep -q check-constraints; then
    echo "Checking sibling package constraints for $repoSlug..."
    docker exec php sh -c "cd /var/www/html/$repoSlug && composer check-constraints" || {
        echo "Sibling constraint check failed, aborting." >&2
        exit 1
    }
fi

if [ -z "$message" ]; then
    echo "Enter the tag message (end with Ctrl-D):"
    message=$(cat)
fi

if [ -z "$message" ]; then
    echo "Empty tag message - aborting." >&2
    exit 1
fi

git tag -a "$version" -m "$message"
git push origin "$version"

echo "Tagged and pushed ${repoSlug}@${version}"

cdOriginalPath
