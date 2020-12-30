# Obelisk Template

A template to make it easier to develop obelisk apps inside a docker container.

## Setup

Note: this assumes you have installed Docker and gnumake.

1. Run `make shell` to enter a shell with obelisk installed. The first time it will initialize the current directory with `ob init --force`. It might take a while.
1. Run `ob run` to start the server.

## Heroku Deploy

Note: this assumes have the [`heroku`](https://devcenter.heroku.com/articles/heroku-cli) command installed and you are logged in to heroku. To install on MacOS `brew tap heroku/brew && brew install heroku`. To install on Ubuntu `sudo snap install --classic heroku`.

1. Exit the shell and run `make heroku-deploy`.