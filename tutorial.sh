
########################################################################################################################
# Getting Started - https://concourse-ci.org/quick-start.html
########################################################################################################################
# This downloads the set up for concourse in a docker-composer file
# for windows 10 I just went to the url c/p the compose in this folder
wget https://concourse-ci.org/docker-compose.yml

# creates the environment
docker-compose up -d

# Open a browser and go to 127.0.0.1:8080 and login
# the credentials are stated in the docker-compose file on
# lines 24 & 25.  From there you download the cli tool in the
# top left corner.  You need to then place the path to the
# exe in your environment variables.

# target your local Concourse as the test user
# this is used to store tokens on your running machine
# inorder to login.
fly -t tutorial login -c http://localhost:8080 -u test -p test

# I think there can also be errors from the cookies or saves from the browser.
# It was not working for me when I would try to log back in using chrome.  I started
# a new session in cognito mode and it worked. I had to restart my computer inorder to
# get the token off the browser.

# After you finish this, if you are able to login you can start making pipelines.

########################################################################################################################
# Deploy Pipeline
########################################################################################################################

git clone https://github.com/starkandwayne/concourse-tutorial.git
cd concourse-tutorial/tutorials/basic/task-hello-world
fly -t tutorial execute -c task_hello_world.yml

# Go to the url below to see the pipeline.  It will not show up automatically.
# http://localhost:8080/builds/1

# Create your own docker image for concourse
# https://concoursetutorial.com/miscellaneous/docker-images

########################################################################################################################
# Tasks
########################################################################################################################

# So Concourse supports inputs into tasks to pass in files/folders for processing.

# Example of tasks is in C:\Users\ryan.schulte\PycharmProjects\DFS\concourse\concourse-tutorial\tutorials\basic\task-inputs
cd ../task-inputs
fly -t tutorial e -c no_inputs.yml

# if you run the below it will fail because there is no input specified
fly -t tutorial e -c inputs_required.yml
# you can specify the input with -i
fly -t tutorial e -c inputs_required.yml -i some-important-input=.
# if you look at what we are running it will list the dir contents for whatever one you put.
# for an example, see below
fly -t tutorial e -c inputs_required.yml -i some-important-input=../task-hello-world

########################################################################################################################
# Tasks Scripts
########################################################################################################################

# The inputs feature of a task allows us to pass in two types of inputs:
#     - requirements/dependencies to be processed/tested/compiled
#     - task scripts to be executed to perform complex behavior



########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################

########################################################################################################################
# Resource utilization - https://concourse-ci.org/postgresql-node.html
########################################################################################################################
# Concourse is constantly running queries which can cause cpu and
# other server level things to throttle.  From the documentation
# they state there is really not much you can do besides monitor
# the situation.
# From the docs
# CPU
# "Expect to feed your database with at least a couple cores, ideally
# four to eight. Monitor this closely as the size of your deployment and
# the amount of traffic it's handling increases, and scale accordingly."
# Disk Space
# "all build logs are stored in the database. This is the primary source of
# disk usage. To mitigate this, users can configure job.build_logs_to_retain
# on a job, but currently there is no operator control for this setting.
# As a result, disk usage on the database can grow arbitrarily large."

########################################################################################################################
# Install fly cli on Linux
########################################################################################################################
# Download from github - https://github.com/concourse/concourse/releases/tag/v6.5.1
git clone https://github.com/concourse/concourse/releases/tag/v6.5.1 # not sure you would do it this way, need to verify

# unpackage to correct directory
tar -zxf concourse-*.tgz -C /usr/local

# From there, you can either add /usr/local/concourse/bin to your $PATH,
# or just execute /usr/local/concourse/bin/concourse directly.

########################################################################################################################
# Configuring concourse
########################################################################################################################
# You can configure concourse one of two ways.  Either create a bunch of
# environment variables or use the flags in the fly cli.

########################################################################################################################
# Concourse Key Configuration
########################################################################################################################
# Concourse's various components use RSA keys to verify tokens and worker registration requests.
#
# A minimal deployment will require the following keys:
#
#    session_signing_key - Used by the web node for signing and verifying user session tokens.
#    tsa_host_key - Used by the web node for the SSH worker registration gateway server ("TSA").
#    * The public key is given to each worker node to verify the remote host when connecting via SSH.
#    worker_key (one per worker) - Each worker node verifies its registration with the web node via a SSH key.
#
# The public key must be listed in the web node's authorized keys configuration in order for the worker to register.

# Generate the keys
concourse generate-key -t rsa -f ./session_signing_key
concourse generate-key -t ssh -f ./tsa_host_key
concourse generate-key -t ssh -f ./worker_key

# Generate a key location
cp worker_key.pub authorized_worker_keys

########################################################################################################################
# Web Node
########################################################################################################################
# The web node is responsible for running the web UI, API, and as well as performing all pipeline scheduling.
# It's basically the brain of Concourse.

# Make the user info for the web node
# You'll probably want to change those to sensible values, and later you may want to configure a proper auth provider
# we use LDAP so you would follow - https://concourse-ci.org/ldap-auth.html
CONCOURSE_ADD_LOCAL_USER=myuser:mypass
CONCOURSE_MAIN_TEAM_LOCAL_USER=myuser

# This sets the keys you made above.
CONCOURSE_SESSION_SIGNING_KEY=path/to/session_signing_key
CONCOURSE_TSA_HOST_KEY=path/to/tsa_host_key
CONCOURSE_TSA_AUTHORIZED_KEYS=path/to/authorized_worker_keys

CONCOURSE_POSTGRES_HOST=127.0.0.1 # default
CONCOURSE_POSTGRES_PORT=5432      # default
CONCOURSE_POSTGRES_DATABASE=atc   # default
CONCOURSE_POSTGRES_USER=my-user
CONCOURSE_POSTGRES_PASSWORD=my-password

# If you're running PostgreSQL locally, you can probably just point it to the socket and rely on the peer auth:
CONCOURSE_POSTGRES_SOCKET=/var/run/postgresql

# Now that everything's set, run:
concourse web
# All logs will be emitted to stdout, with any panics or lower-level errors being emitted to stderr.

########################################################################################################################
# Deploy Pipeline
########################################################################################################################

git clone https://github.com/starkandwayne/concourse-tutorial.git
cd concourse-tutorial/tutorials/basic/task-hello-world
fly -t tutorial execute -c task_hello_world.yml

fly -t tutorial login -c http://localhost:8080 -u test -p test

# list all concourse pipelines
fly targets

# tells the status of
fly -t <name of pipeline> status
# example:
fly -t tutorial status

# command to provide the token for login
fly -t main -k -c <url of pipeline>

# The reason that you can select any base image (or image_resource when configuring a task) is that this allows your
# task to have any prepared dependencies that it needs to run. Instead of installing dependencies each time during a
# task you might choose to pre-bake them into an image to make your tasks much faster.
#     Basically build your premade image so you don't have to set one up using concourse.

# Making docker images using concourse
#     http://concoursetutorial.com/miscellaneous/docker-images/
#     These are in the files @ concourse/concourse-tutorial/tutorials/miscellaneous/docker-images/

########################################################################################################################
# Resource Types
########################################################################################################################
# There are a ton of 3rd party resource types.  Below is the link to them.  Of interest are bitbucket, docker-compose.
https://resource-types.concourse-ci.org/

# timer resource - sets an interval to check for changes and rerun the pipeline.
https://github.com/concourse/time-resource

