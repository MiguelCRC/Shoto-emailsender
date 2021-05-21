# Shoto-emailsender
## _Email sender to update status to managers_

[![Build Status](https://travis-ci.com/MiguelCRC/Shoto-emailsender.svg?branch=main)](https://google.com)

This is the Backend for the **Shoto** web application,
NodeJS-powered and other top technologies.

## Features

- Login with unique account
- Create an account
- Capable of identify which email is needed to send
- Export reports like:
    - History by **User**
    - **Specific** email from all Users

## Tech

Shotos Backend uses a number of open source projects to work properly:

- [Node.js] - evented I/O for the backend
- [ExpressJs] - fast node.js network app framework
- [Docker] -  make it easier to create, deploy, and run applications by using containers
- [Postgres] - object-relational Data Base
- [Sequelize] - Object-Relational Mapper(ORM) for DB
- [Travis CI] for Continuous Integration

And of course **Shoto Emailsender** itself is open source with a [public repository][shoto]
 on GitHub.

## How it was created

### Install [NVM] (Node Version Manager)
```sh
$ sudo apt-get update
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.38.0/install.sh | bash
```
These commands will download and run the installation script directly from the Github repository.

This installation script will download the NVM repository in to the ``~/.nvm`` directory and add the source line to your shell profile (``~/.bash_profile``, ``~/.zshrc``, or ``~/.profile``).

### Install Node with the NVM 
```sh
$ nvm install <version> || --lts
```

### Install Node Express
```sh
$ npm install express-generator -g
```

### Create Express Project 
We use Express Generator to create all the directory structure
```sh
$ express <myapp>
```
### Create and Configure .gitignore
Create the file and name it ``.gitignore``, inside write all stuff you want git to ignore
Example:
```sh
# Dev env vars
local.env
# Dependency directories
node_modules/
jspm_packages/
```

### On app.js change var declaration to let
This because scoping rules. Variables declared by ``var`` keyword are scoped to the immediate function body (hence the function scope) while ``let`` variables are scoped to the immediate enclosing block denoted by ``{ }`` (hence the block scope).

### Docker and docker-compose installation
Install Docker Engine
```sh
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```
To install a specific version of Docker Engine, list the available versions in the repo, then select and install:

- List the versions available in your repo:
```sh
$ apt-cache madison docker-ce
```
- Install a specific version using the version string from the second column.
```sh
 sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
```
Install docker-compose
 - Run this command for download docker-compose:
 ```sh
 $ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 ```
- Apply executable permissions to the binary:
```sh
$ sudo chmod +x /usr/local/bin/docker-compose
```
### Install Sequelize and all dependencies to work with Postgres

#### Install Sequelize & Sequelize-cli
```sh
$ npm install sequelize --save
```
```sh
$ npm install sequelize-cli --save
```
```sh
$ npx sequelize-cli init
```
#### Install pg & pg-hstore
```sh
$ npm install pg --save
```
```sh
$ npm install pg-hstore --save
```
### Other needed installations
#### Nodemon
Is a tool that helps develop node.js based applications by automatically restarting the node application when file changes in the directory are detected.
```sh
$ npm install nodemon --save
```
#### Eslint
Is a tool for identifying and reporting on patterns found in ECMAScript/JavaScript code, with the goal of making code more consistent and avoiding bugs.
```sh
$ npm install eslint --save
$ npx eslint --init
```
### Configure docker-compose files
On the project root, create a new folder called ``compose`` and inside a new folder called ``local`` which has a folder called ``api``
```
project
└───compose 
│   └───local
│       └───api
│       |       Dockerfile
│       |       entrypoint.sh
│       |       start.sh
```
Inside de ``api`` folder create 3 files for the configuration of docker-compose:
- Docker file - is a text document that contains all the commands a user could call on the command line to assemble an image.

Code inside:

```sh
FROM node:lts-alpine
ENV NODE_ENV development

WORKDIR /app

RUN apk --update add postgresql-client python2 alpine-sdk

COPY ./package.json /app/package.json
COPY ./package-lock.json /app/package-lock.json
COPY ./compose/local/api/entrypoint.sh /entrypoint.sh
COPY ./compose/local/api/start.sh /start.sh

RUN sed -i 's/\r//' /entrypoint.sh \
    && sed -i 's/\r//' /start.sh \
    && chmod +x /entrypoint.sh \
    && chmod +x /start.sh

RUN chown -R node:node /app \
    && chown -R node:node /entrypoint.sh \
    && chown -R node:node /start.sh 

USER node
RUN npm install

ENTRYPOINT [ "/entrypoint.sh" ]
```
- entrypoint . sh - is a script that will run inside your container ``builder`` when you execute ``docker-compose up`` command.

Code inside:
```sh
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
```
- start . sh - is a script that will knows how ``docker-compose up`` command would execute some issues or even a app crash.

Our code:
```
#!/bin/sh
export DEBUG=emailsenderapi:*
/app/node_modules/.bin/nodemon -L ./bin/www
```
### local.yml file
In order to do something useful with containers, they have to be arranged ``- orchestrated -`` as part of a project, usually referred to as an ‘application’. This orchestrated is the ``local.yml`` file. It located on the project root.

Our file code:
```
version: "3"

services:
  api:
    build:
      context: .
      dockerfile: ./compose/local/api/Dockerfile
    volumes:
      - /app/node_modules
      - .:/app
    env_file:
      - local.env
    ports:
      - "3000:3000"
    networks:
      - <localnetwork>
    depends_on:
      - db
    command: /start.sh
  
  db:
    image: postgres:11-alpine
    volumes:
      - postgres_data_local:/var/lib/postgresql/data
    env_file:
      - local.env
    networks:
      - <localnetwork>
    ports:
      - "5432:5432"

volumes:
  postgres_data_local: {}

networks:
  <localnetwork>: {}
```

### From config.json to config.js
Change the extension of the file ``config.json`` to ``config.js``, located at the directory called ``config``
Also its need to change the code in the file and transform all to a js script
```js
module.exports = {
	'development': {
		'username': process.env.POSTGRES_USER,
		'password': process.env.POSTGRES_PASSWORD,
		'database': process.env.POSTGRES_DB,
		'host': process.env.POSTGRES_HOST,
		'dialect': 'postgres',
	},
	'test': {
		'username': process.env.POSTGRES_USER,
		'password': process.env.POSTGRES_PASSWORD,
		'database': process.env.POSTGRES_DB,
		'host': process.env.POSTGRES_HOST,
		'dialect': 'postgres',
	},
	'production': {
		'username': process.env.POSTGRES_USER,
		'password': process.env.POSTGRES_PASSWORD,
		'database': process.env.POSTGRES_DB,
		'host': process.env.POSTGRES_HOST,
		'dialect': 'postgres',
	}
}
```
The Shoto Backend uses a ```.env``` file where are located all the global variables and those are called on the config,js file.
Also with this change is necesary to check the file ``./models/index.js`` on line ``8`` and change ``config.json -> config.js``
## Installation

Shoto Emailsender Backend requires [Node.js](https://nodejs.org/) v14+ to run.

If its the first time running the project:

Install the dependencies and devDependencies and start Docker.

```sh
$ npm install
```
```sh
$ docker-compose -f local.yml build || --no-cache
```
To get up the container
```sh
$ docker-compose -f local.yml up
```
To down the container
```sh
$ docker-compose -f local.yml down
```

## Other usefull commands
### Create a Migration
```sh
$ docker-compose -f local.yml run --rm api npx sequelize-cli model:generate --name <Name> --attributes <name:type,name1:type,...>
```
### Run Migrations
```sh
$ docker-compose -f local.yml run --rm api npx sequelize-cli db:migrate
```
### Undo Migrations
```sh
$ docker-compose -f local.yml run --rm api npx sequelize-cli db:migrate:undo:all
```

### Create Seeder
```sh
$ docker-compose -f local.yml run --rm api npx sequelize-cli seed:generate --name <seederName>
```
### Run Seeders
For all Seeders
```sh
$ docker-compose -f local.yml run --rm api npx sequelize-cli db:seed:all
```
For one Seeder
```sh
$ docker-compose -f local.yml run --rm api npx sequelize-cli db:seed --seed <seederName>
```
### Enter to Data Base
Its necessary that the service is up
```sh
$  docker-compose -f local.yml exec db sh
```
Once there
```sh
/ # psql <DBNAME> <DBUSER>
```
## License

MIT

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [ExpressJs]:<https://expressjs.com/es/starter/generator.html>
   [Postgres]:<https://www.postgresql.org/>
   [Sequelize]:<https://sequelize.org/>
   [Travis CI]:<https://travis-ci.com/>
   [shoto]: <https://github.com/MiguelCRC/Shoto-emailsender>
   [Node.js]: <http://nodejs.org>
   [Docker]:<https://docs.docker.com/>
   [NVM]:<https://github.com/nvm-sh/nvm>
   