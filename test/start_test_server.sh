#!/bin/sh

# Note, this could just as easily be changed to a ruby script

# Support installations of Rails using MacPorts:
PATH="/opt/local/bin:$PATH"

# Switch to the Sample rails app
cd sample_rails_app

# Kill any previously running instance
kill `cat tmp/pids/server.pid` || echo "kill previous server failed, ignoring"

# Prepare the rails test
rake db:migrate
rake db:test:prepare
rake db:populate RAILS_ENV=test

# Run the rails server
./script/server -e test -p 36313 -d
