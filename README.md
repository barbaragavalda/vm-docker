# 0. First things first:
First you need to 

# 1. Working with docker
VM needs the docker interface up and running, so every time you're working with this you should first go and open the desktop application.

After the application has started you need to open your terminal and change directory to the scripts directory, in your case this should be done with:
```bash
cd /Users/barbaragavalda/Documents/OPTISISTEM/VM/system/scripts
```
After this you can use the scripts described in this guide.

## 1.1 Docker scripts
No need for further explanation on this commands.
```bash
sh docker.sh start 
```
```bash
sh docker.sh stop
```
```bash
sh docker.sh restart
```
Obviously if docker is not running your hosts won't work.

# 2. Creating and deleting host
You can create and delete host with the `host.sh` script. It takes the following arguments:
```bash
sh host.sh <command> <domain>
```
for example:
```bash
sh host.sh create example.local
```
or:
```bash
sh host.sh delete example.local
```

## 2.1 Arguments

**command**: is either `create` or `delete` with obvious consequences. Both scripts will require elevation as they write in the ´/etc/hosts´ file.

**domain**: it's the domain you want to create, for example `example.local`. **DO NOT add protocols such as `http` or `https`**. Also subdomains are not supported by now, though they may work.

## 2.2 Create
Creating a new *example.local* host will:
* Add a folder in `storage/src/example-local` and it'll place an example `index.html` on it for test pourpouses. Feel free to delete this file and checkout your git repository in there. This path is ignored by git so any changes in there won't be pushed or pulled.
* Add a file in `storage/config/apache/example-local.conf` with it's apache configuration. This can be overriden manually in case you need something special. If you need to restore your base configuration there's a template file under `templates/apache/new-vhost.conf`. Configuration includes `http` and `https` protocols but **certificates are not** created.
* Add host configuration in `/etc/hosts` file
* Restart docker
* Your new host should be ready to go at http://example.local

## 2.3 Delete
Deleting an *example.local* host will:
* Remove `storage/src/example-local`
* Remove `storage/config/apache/example-local.conf`
* Remove host configuration in `/etc/hosts` file
* Restart docker
* Your new host is no longer accessible at http://example.local

## 3.1. Credentials
### 3.1.1. Database
* HOST: mariadb
* USER: optisistem
* PASSWORD: rtZYS9wJ7HWWNK

# 4. Scaffolding a new project

`freimguork-skeleton` (`storage/src/freimguork-skeleton`) is the starting template for any new
project built on `freimguork-core` (+ `freimguork-appacman` for the admin panel). Instead of
copying it by hand, filling in every placeholder and setting up the host/database yourself,
`create-project.sh` automates all of it:

```bash
sh create-project.sh <slug> <prod-domain> [project-name] [description]
```
for example:
```bash
sh create-project.sh tv-tracker tvtracker.com "TV Tracker" "Track what you're watching"
```

## 4.1 Arguments

**slug**: lowercase, hyphenated (e.g. `tv-tracker`). Used for the local host (`<slug>.local`), the
project folder (`storage/src/<slug>-local`), the database name and the composer package name.

**prod-domain**: the real production domain, e.g. `tvtracker.com`. **DO NOT add protocols**.

**project-name** (optional): human-readable name. Defaults to Title Case of the slug.

**description** (optional): short description. Defaults to empty.

## 4.2 What it does

Running it will:
* Create the host/vhost exactly like `host.sh create <slug>.local` does (see section 2) - same
  elevation/`/etc/hosts` requirement, same full docker restart at the end
* Copy `freimguork-skeleton` into the new project folder and `git init` it there (its own history,
  not a fork of the skeleton repo)
* Fetch the latest jQuery release and drop it into `web/static/js/`, replacing the version bundled
  in the skeleton (see "Known gotcha" below)
* Fill in every `{{...}}` placeholder (`composer.json`, `base_domain.php`, `Home.php`, `db.sql`, the
  locale `.po` file) with the values above
* Copy every `config/**/*.php.dist` to its real counterpart and fill in the shared DB credentials
  (section 3.1.1) plus a freshly generated encryption secret per environment
* Create the project's database (aborts instead of reusing it if a database with that name already
  exists) and import the base Appacman schema (`db.sql`)
* Run `composer install`, which also publishes the Appacman/AdminLTE assets into `web/`

It will abort early, before touching anything, if the project folder or the database already
exist - it never overwrites or reuses either.

**Not automated on purpose**: creating the first Appacman admin user. `appacman_user.name`/`email`
are encrypted and `password` is hashed under that project's own freshly generated secret, so it
needs a real password you choose - see "First admin user" in the new project's `README.md`.

**Known gotcha**: `code.jquery.com/jquery-latest.min.js` (the CDN's own "always latest" alias) has
been frozen at jQuery v1.11.1 for years - don't use it. The script instead asks npm's registry for
the actual latest version and downloads that exact build by version number.

//TODO AFEGIR COM ES FA EL COMPOSE