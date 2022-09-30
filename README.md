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

//TODO AFEGIR COM ES FA EL COMPOSE