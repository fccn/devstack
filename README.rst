Open edX Devstack |Build Status|
================================

Get up and running quickly with Open edX services.

This project replaces the older Vagrant-based devstack with a
multi-container approach driven by `Docker Compose`_.

A Devstack installation includes the following Open edX components:

* The Learning Management System (LMS)
* Open edX Studio
* Discussion Forums
* Open Response Assessments (ORA)
* E-Commerce
* Credentials
* Notes
* Course Discovery
* XQueue
* Open edX Search
* A demonstration Open edX course

It also includes the following extra components:

* XQueue
* The components needed to run the Open edX Analytics Pipeline. This is the primary extract, transform, and load (ETL) tool that extracts and analyzes data from the other Open edX services.
* The Program Console micro-frontend
* edX Registrar service.

Where to Find Help
------------------

There are a number of places to get help, including mailing lists and real-time chat. Please choose an appropriate venue for your question. This helps ensure that you get good prompt advice, and keeps discussion focused. For details of your options, see the `Community`_ pages.

FYI
---

You should run all ``make`` commands described below on your local machine, *not*
from within a VM (virtualenvs are ok, and in fact recommended) as these commands
are for standing up a new docker based VM.

Prerequisites
-------------

You will need to have the following installed:

- make
- python 3
- docker

This project requires **Docker 17.06+ CE**.  We recommend Docker Stable, but
Docker Edge should work as well.

**NOTE:** Switching between Docker Stable and Docker Edge will remove all images and
settings.  Don't forget to restore your memory setting and be prepared to
provision.

For macOS users, please use `Docker for Mac`_. Previous Mac-based tools (e.g.
boot2docker) are *not* supported.

Since a Docker-based devstack runs many containers,
you should configure Docker with a sufficient
amount of resources. We find that `configuring Docker for Mac`_ with
a minimum of 2 CPUs and 8GB of memory does work.

`Docker for Windows`_ may work but has not been tested and is *not* supported.

If you are using Linux, use the ``overlay2`` storage driver, kernel version
4.0+ and *not* ``overlay``. To check which storage driver your
``docker-daemon`` uses, run the following command.

.. code:: sh

   docker info | grep -i 'storage driver'

Using the Latest Images
-----------------------

New images for our services are published frequently.  Assuming that you've followed the steps in `Getting Started`_
below, run the following sequence of commands if you want to use the most up-to-date versions of the devstack images.

.. code:: sh

    make down
    make dev.pull
    make dev.up

This will stop any running devstack containers, pull the latest images, and then start all of the devstack containers.

Getting Started
---------------

All of the services can be run by following the steps below. For analyticstack, follow `Getting Started on Analytics`_.

1. Install the requirements inside of a `Python virtualenv`_.

   .. code:: sh

       make requirements

   This will install docker-compose and other utilities into your virtualenv.

2. The Docker Compose file mounts a host volume for each service's executing
   code. The host directory defaults to be a sibling of this directory. For
   example, if this repo is cloned to ``~/workspace/devstack``, host volumes
   will be expected in ``~/workspace/course-discovery``,
   ``~/workspace/ecommerce``, etc. These repos can be cloned with the command
   below.

   .. code:: sh

       make dev.clone  # or, `make dev.clone.ssh` if you have SSH keys set up.

   You may customize where the local repositories are found by setting the
   DEVSTACK\_WORKSPACE environment variable.

   (macOS only) Share the cloned service directories in Docker, using
   **Docker -> Preferences -> File Sharing** in the Docker menu.

3. Pull any changes made to the various images on which the devstack depends.

   .. code:: sh

       make dev.pull

3. (Optional) You have an option to use nfs on MacOS which will improve the performance significantly, to set it up ONLY ON MAC, do
    .. code:: sh

        make dev.nfs.setup


4. Run the provision command, if you haven't already, to configure the various
   services with superusers (for development without the auth service) and
   tenants (for multi-tenancy).

   **NOTE:** When running the provision command, databases for ecommerce and edxapp
   will be dropped and recreated.

   The username and password for the superusers are both ``edx``. You can access
   the services directly via Django admin at the ``/admin/`` path, or login via
   single sign-on at ``/login/``.

   Default:

   .. code:: sh

       make dev.provision

   Provision using `docker-sync`_:

   .. code:: sh

       make dev.sync.provision

     Provision using NFS:

   .. code:: sh

       make dev.nfs.provision

   This is expected to take a while, produce a lot of output from a bunch of steps, and finally end with ``Provisioning complete!``

5. Start the services. This command will mount the repositories under the
   DEVSTACK\_WORKSPACE directory.

   **NOTE:** it may take up to 60 seconds for the LMS to start, even after the ``make dev.up`` command outputs ``done``.

   Default:

   .. code:: sh

       make dev.up

   Start using `docker-sync`_:

   .. code:: sh

       make dev.sync.up

   Start using NFS:

   .. code:: sh

       make dev.nfs.up


After the services have started, if you need shell access to one of the
services, run ``make <service>-shell``. For example to access the
Catalog/Course Discovery Service, you can run:

.. code:: sh

    make discovery-shell

To see logs from containers running in detached mode, you can either use
"Kitematic" (available from the "Docker for Mac" menu), or by running the
following:

.. code:: sh

    make logs

To view the logs of a specific service container run ``make <service>-logs``.
For example, to access the logs for Ecommerce, you can run:

.. code:: sh

    make ecommerce-logs

To reset your environment and start provisioning from scratch, you can run:

.. code:: sh

    make destroy

For information on all the available ``make`` commands, you can run:

.. code:: sh

    make help

Usernames and Passwords
-----------------------

The provisioning script creates a Django superuser for every service.

::

    Email: edx@example.com
    Username: edx
    Password: edx

The LMS also includes demo accounts. The passwords for each of these accounts
is ``edx``.

  .. list-table::
   :widths: 20 60
   :header-rows: 1

   * - Account
     - Description
   * - ``staff@example.com``
     - An LMS and Studio user with course creation and editing permissions.
       This user is a course team member with the Admin role, which gives
       rights to work with the demonstration course in Studio, the LMS, and
       Insights.
   * - ``verified@example.com``
     - A student account that you can use to access the LMS for testing
       verified certificates.
   * - ``audit@example.com``
     - A student account that you can use to access the LMS for testing course
       auditing.
   * - ``honor@example.com``
     - A student account that you can use to access the LMS for testing honor
       code certificates.

Service List
------------

These are the edX services that Devstack can provision, pull, run, attach to, etc.
Each service is accessible at ``localhost`` on a specific port.
The table below provides links to the homepage, API root, or API docs of each service,
as well as links to the repository where each service's code lives.

The services marked as ``Default`` are provisioned/pulled/run whenever you run
``make dev.provision`` / ``make dev.pull`` / ``make dev.up``, respectively.

The extra services are provisioned/pulled/run when specifically requested (e.g.,
``make dev.provision.xqueue`` / ``make dev.pull.xqueue`` / ``make dev.up.xqueue``).

+---------------------------+-------------------------------------+----------------+------------+
| Service                   | URL                                 | Type           | Role       |
+===========================+=====================================+================+============+
| `lms`_                    | http://localhost:18000/             | Python/Django  | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `studio`_                 | http://localhost:18010/             | Python/Django  | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `forum`_                  | http://localhost:44567/api/v1/      | Ruby/Sinatra   | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `discovery`_              | http://localhost:18381/api-docs/    | Python/Django  | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `ecommerce`_              | http://localhost:18130/dashboard/   | Python/Django  | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `credentials`_            | http://localhost:18150/api/v2/      | Python/Django  | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `edx_notes_api`_          | http://localhost:18120/api/v1/      | Python/Django  | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `frontend-app-publisher`_ | http://localhost:18400/             | MFE (React.js) | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `gradebook`_              | http://localhost:1994/              | MFE (React.js) | Default    |
+---------------------------+-------------------------------------+----------------+------------+
| `registrar`_              | http://localhost:18734/api-docs/    | Python/Django  | Extra      |
+---------------------------+-------------------------------------+----------------+------------+
| `program-console`_        | http://localhost:1976/              | MFE (React.js) | Extra      |
+---------------------------+-------------------------------------+----------------+------------+
| `xqueue`_                 | http://localhost:18040/api/v1/      | Python/Django  | Extra      |
+---------------------------+-------------------------------------+----------------+------------+
| `analyticspipeline`_      | http://localhost:4040/              | Python         | Extra      |
+---------------------------+-------------------------------------+----------------+------------+
| `marketing`_              | http://localhost:8080/              | PHP/Drupal     | Extra      |
+---------------------------+-------------------------------------+----------------+------------+

.. _credentials: https://github.com/edx/credentials
.. _discovery: https://github.com/edx/course-discovery
.. _ecommerce: https://github.com/edx/ecommerce
.. _edx_notes_api: https://github.com/edx/edx-notes-api
.. _forum: https://github.com/edx/cs_comments_service
.. _frontend-app-publisher: https://github.com/edx/frontend-app-publisher
.. _gradebook: https://github.com/edx/frontend-app-gradebook
.. _lms: https://github.com/edx/edx-platform
.. _program-console: https://github.com/edx/frontend-app-program-console
.. _registrar: https://github.com/edx/registrar
.. _studio: https://github.com/edx/edx-platform
.. _lms: https://github.com/edx/edx-platform
.. _analyticspipeline: https://github.com/edx/edx-analytics-pipeline
.. _marketing: https://github.com/edx/edx-mktg
.. _xqueue: https://github.com/edx/xqueue

Getting Started on Analytics
----------------------------

Analyticstack can be run by following the steps below.

**NOTE:** Since a Docker-based devstack runs many containers, you should configure
Docker with a sufficient amount of resources. We find that
`configuring Docker for Mac`_ with a minimum of 2 CPUs and 6GB of memory works
well for **analyticstack**. If you intend on running other docker services besides
analyticstack ( e.g. lms, studio etc ) consider setting higher memory.

1. Follow steps `1` and `2` from `Getting Started`_ section.

2. Before running the provision command, make sure to pull the relevant
   docker images from dockerhub by running the following commands:

   .. code:: sh

       make dev.pull
       make pull.analytics_pipeline

3. Run the provision command to configure the analyticstack.

   .. code:: sh

       make dev.provision.analytics_pipeline

4. Start the analytics service. This command will mount the repositories under the
   DEVSTACK\_WORKSPACE directory.

   **NOTE:** it may take up to 60 seconds for Hadoop services to start.

   .. code:: sh

       make dev.up.analytics_pipeline

5. To access the analytics pipeline shell, run the following command. All analytics
   pipeline job/workflows should be executed after accessing the shell.

   .. code:: sh

     make analytics-pipeline-shell

   - To see logs from containers running in detached mode, you can either use
     "Kitematic" (available from the "Docker for Mac" menu), or by running the
     following command:

      .. code:: sh

        make logs

   - To view the logs of a specific service container run ``make <service>-logs``.
     For example, to access the logs for Hadoop's namenode, you can run:

      .. code:: sh

        make namenode-logs

   - To reset your environment and start provisioning from scratch, you can run:

      .. code:: sh

        make destroy

     **NOTE:** Be warned! This will remove all the containers and volumes
     initiated by this repository and all the data ( in these docker containers )
     will be lost.

   - For information on all the available ``make`` commands, you can run:

      .. code:: sh

        make help

6. For running acceptance tests on docker analyticstack, follow the instructions in the
   `Running analytics acceptance tests in docker`_ guide.
7. For troubleshooting docker analyticstack, follow the instructions in the
   `Troubleshooting docker analyticstack`_ guide.

Useful Commands
---------------

``make dev.up`` can take a long time, as it starts all services, whether or not
you need them. To instead only start a single service and its dependencies, run
``make dev.up.<service>``. For example, the following will bring up LMS
(along with Memcached, MySQL, and devpi), but it will not bring up Discovery,
Credentials, etc:

.. code:: sh

    make dev.up.lms

Similarly, ``make dev.pull`` can take a long time, as it pulls all services' images,
whether or not you need them.
To instead only pull images required by your service and its dependencies,
run ``make dev.pull.<service>``.

Finally, ``make dev.provision.services.<service1>+<service2>+...``
can be used in place of ``make dev.provision`` in order to run an expedited version of
provisioning for a specific set of services.
For example, if you mess up just your
Course Discovery and Registrar databases,
running ``make dev.provision.services.discovery+registrar``
will take much less time than the full provisioning process.
However, note that some services' provisioning processes depend on other services
already being correcty provisioned.
So, when in doubt, it may still be best to run the full ``make dev.provision``.

Sometimes you may need to restart a particular application server. To do so,
simply use the ``docker-compose restart`` command:

.. code:: sh

    docker-compose restart <service>

In all the above commands, ``<service>`` should be replaced with one of the following:

-  credentials
-  discovery
-  ecommerce
-  lms
-  edx_notes_api
-  studio
-  registrar
-  gradebook
-  program-console
-  frontend-app-learning
-  frontend-app-publisher

If you'd like to add some convenience make targets, you can add them to a ``local.mk`` file, ignored by git.

Payments
--------

The ecommerce image comes pre-configured for payments via CyberSource and PayPal. Additionally, the provisioning scripts
add the demo course (``course-v1:edX+DemoX+Demo_Course``) to the ecommerce catalog. You can initiate a checkout by visiting
http://localhost:18130/basket/add/?sku=8CF08E5 or clicking one of the various upgrade links in the LMS. The following
details can be used for checkout. While the name and address fields are required for credit card payments, their values
are not checked in development, so put whatever you want in those fields.

- Card Type: Visa
- Card Number: 4111111111111111
- CVN: 123 (or any three digits)
- Expiry Date: 06/2025 (or any date in the future)

PayPal (same for username and password): devstack@edx.org

Marketing Site
--------------

Docker Compose files useful for integrating with the edx.org marketing site are
available. This will NOT be useful to those outside of edX. For details on
getting things up and running, see
https://openedx.atlassian.net/wiki/display/OpenDev/Marketing+Site.

How do I develop on an installed Python package?
------------------------------------------------

If you want to modify an installed package ??? for instance ``edx-enterprise`` or ``completion`` ??? clone the repository in
``~/workspace/src/your-package``. Next, ssh into the appropriate docker container (``make lms-shell``),
run ``pip install -e /edx/src/your-package``, and restart the service.


How do I build images?
----------------------

There are `Docker CI Jenkins jobs`_ on tools-edx-jenkins that build and push new
Docker images to DockerHub on code changes to either the configuration repository or the IDA's codebase. These images
are tagged according to the branch from which they were built (see NOTES below).
If you want to build the images on your own, the Dockerfiles are available in the ``edx/configuration`` repo.

NOTES:

1. edxapp and IDAs use the ``latest`` tag for configuration changes which have been merged to master branch of
   their repository and ``edx/configuration``.
2. Images for a named Open edX release are built from the corresponding branch
   of each repository and tagged appropriately, for example ``hawthorn.master``
   or ``hawthorn.rc1``.
3. The elasticsearch used in devstack is built using elasticsearch-devstack/Dockerfile and the ``devstack`` tag.

BUILD COMMANDS:

.. code:: sh

    git checkout master
    git pull
    docker build -f docker/build/edxapp/Dockerfile . -t edxops/edxapp:latest

.. code:: sh

    git checkout master
    git pull
    docker build -f docker/build/ecommerce/Dockerfile . -t edxops/ecommerce:devstack

The build commands above will use your local configuration, but will pull
application code from the master branch of the application's repository. If you
would like to use code from another branch/tag/hash, modify the ``*_VERSION``
variable that lives in the ``ansible_overrides.yml`` file beside the
``Dockerfile``. Note that edx-platform is an exception; the variable to modify is ``edx_platform_version``
and not ``EDXAPP_VERSION``.

For example, if you wanted to build tag ``release-2017-03-03`` for the
E-Commerce Service, you would modify ``ECOMMERCE_VERSION`` in
``docker/build/ecommerce/ansible_overrides.yml``.

How do I run the images for a named Open edX release?
-----------------------------------------------------

#. Set the ``OPENEDX_RELEASE`` environment variable to the appropriate image
   tag; "hawthorn.master", "zebrawood.rc1", etc.  Note that unlike a server
   install, ``OPENEDX_RELEASE`` should not have the "open-release/" prefix.
#. Check out the appropriate branch in devstack, e.g. ``git checkout open-release/ironwood.master``
#. Use ``make dev.checkout`` to check out the correct branch in the local
   checkout of each service repository once you've set the ``OPENEDX_RELEASE``
   environment variable above.
#. ``make dev.pull`` to get the correct images.

All ``make`` target and ``docker-compose`` calls should now use the correct
images until you change or unset ``OPENEDX_RELEASE`` again.  To work on the
master branches and ``latest`` images, unset ``OPENEDX_RELEASE`` or set it to
an empty string.

How do I run multiple named Open edX releases on same machine?
--------------------------------------------------------------
You can have multiple isolated Devstacks provisioned on a single computer now. Follow these directions to switch between the named releases.

#. Bring down any running containers by issuing a `make stop.all`. 
#. The ``COMPOSE_PROJECT_NAME`` variable is used to define Docker namespaced volumes and network based on this value, so changing it will give you a separate set of databases. This is handled for you automatically by setting the ``OPENEDX_RELEASE`` environment variable in ``options.mk`` (e.g. ``COMPOSE_PROJECT_NAME=devstack-juniper.master``. Should you want to manually override this edit the ``options.local.mk`` in the root of this repo and create the file if it does not exist. Change the devstack project name by adding the following line:
   ``COMPOSE_PROJECT_NAME=<your-alternate-devstack-name>`` (e.g. ``COMPOSE_PROJECT_NAME=secondarydevstack``)
#. Perform steps in `How do I run the images for a named Open edX release?`_ for specific release.
#. Follow the steps in `Getting Started`_ section to update requirements (e.g. ``make requirements``) and provision (e.g. ``make dev.provision``) the new named release containers.

As a specific example, if ``OPENEDX_RELEASE`` is set in your environment as ``juniper.master``, then ``COMPOSE_PROJECT_NAME`` will default to ``devstack-juniper.master`` instead of ``devstack``.

The implication of this is that you can switch between isolated Devstack databases by changing the value of the ``OPENEDX_RELEASE`` environment variable.

Switch between your Devstack releases by doing the following:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Bring down the containers by issuing a ``make stop.all`` for the running release.
#. Follow the instructions from the `How do I run multiple named Open edX releases on same machine?`_ section.
#. Edit the project name in ``options.local.mk`` or set the ``OPENEDX_RELEASE`` environment variable and let the ``COMPOSE_PROJECT_NAME`` be assigned automatically. 
#. Bring up the containers with ``make dev.up``.

**NOTE:** Additional instructions on switching releases using `direnv` can be found in `How do I switch releases using 'direnv'?`_ section.

Examples of Docker Service Names After Setting the ``COMPOSE_PROJECT_NAME`` variable. Notice that the **devstack-juniper.master** name represents the ``COMPOSE_PROJECT_NAME``.
         
-  edx.devstack-juniper.master.lms          
-  edx.devstack-juniper.master.mysql  

Each instance has an isolated set of databases. This could, for example, be used to quickly switch between versions of Open edX without hitting as many issues with migrations, data integrity, etc.

Unfortunately, this **does not** currently support running Devstacks simultaneously, because we hard-code host port numbers all over the place, and two running containers cannot share the same host port.

Questions & Troubleshooting ??? Multiple Named Open edX Releases on Same Machine
------------------------------------------------------------------------------

This broke my existing Devstack!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 See if the troubleshooting of this readme can help resolve your broken devstack first, then try posting on the `Open edX forums <https://discuss.openedx.org>`__ to see if you have the same issue as any others. If you think you have found a bug, file a CR ticket.
        
I???m getting errors related to ports already being used.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Make sure you bring down your devstack before changing the value of COMPOSE_PROJECT_NAME. If you forgot to, change the COMPOSE_PROJECT_NAME back to its original value, run ``make dev.down``, and then try again.
        
I have custom scripts/compose files that integrate with or extend Devstack. Will those still work?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
With the default value of COMPOSE_PROJECT_NAME = devstack, they should still work. If you choose a different COMPOSE_PROJECT_NAME, your extensions will likely break, because the names of containers change along with the project name.

How do I switch releases using 'direnv'?
----------------------------------------

Follow directions in `Switch between your Devstack releases by doing the following:`_ then make the following adjustments.

Make sure that you have setup each Open edX release in separate directories using `How do I enable environment variables for current directory using 'direnv'?`_ instructions. Open the next release project in a separate code editor, then activate the ``direnv`` environment variables and virtual environment for the next release by using a terminal shell to traverse to the directory with the corresponding release ``.envrc`` file. You may need to issue a ``direnv allow`` command to enable the ``.envrc`` file.

    .. code:: sh

        # You should see something like the following after successfully enabling 'direnv' for the Juniper release.

        direnv: loading ~/open-edx/devstack.juniper/.envrc   
        direnv: export +DEVSTACK_WORKSPACE +OPENEDX_RELEASE +VIRTUAL_ENV ~PATH
        (venv)username@computer-name devstack.juniper %

**NOTE:** Setting of the ``OPENEDX_RELEASE`` should have been handled within the ``.envrc`` file for named releases only and should not be defined for the ``master`` release.

How do I enable environment variables for current directory using 'direnv'?
---------------------------------------------------------------------------
We recommend separating the named releases into different directories, for clarity purposes. You can use `direnv <https://direnv.net/>`__ to define different environment variables per directory::

    .. code::

        # Example showing directory structure for separate Open edX releases.

        /Users/<username>/open-edx ??? root directory for platform development
        |_ ./devstack.master  ??? directory containing all repository information related to the main development release.
        |_ ./devstack.juniper ??? directory containing all repository information related to the Juniper release.

#. Install `direnv` using instructions on https://direnv.net/. Below you will find additional setup at the time of this writing so refer to latest of `direnv` site for additional configuration needed.

#. Setup the following configuration to hook `direnv` for local directory environment overrides. There are two examples for BASH or ZSH (Mac OS X) shells.

    .. code:: sh

        ## ~/.bashrc for BASH shell

        ## Hook in `direnv` for local directory environment overrides.
        ## https://direnv.net/docs/hook.html
        eval "$(direnv hook bash)"

        # https://github.com/direnv/direnv/wiki/Python#bash
        show_virtual_env() {
        if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
            echo "($(basename $VIRTUAL_ENV))"
        fi
        }
        export -f show_virtual_env
        PS1='$(show_virtual_env)'$PS1

        # ---------------------------------------------------

        ## ~/.zshrc for ZSH shell for Mac OS X.

        ## Hook in `direnv` for local directory environment setup.
        ## https://direnv.net/docs/hook.html 
        eval "$(direnv hook zsh)"

        # https://github.com/direnv/direnv/wiki/Python#zsh
        setopt PROMPT_SUBST

        show_virtual_env() {
        if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
            echo "($(basename $VIRTUAL_ENV))"
        fi
        }
        PS1='$(show_virtual_env)'$PS1

#. Setup `layout_python-venv` function to be used in local project directory `.envrc` file.

    .. code:: sh

        ## ~/.config/direnv/direnvrc

        # https://github.com/direnv/direnv/wiki/Python#venv-stdlib-module

        realpath() {
            [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
        }
        layout_python-venv() {
            local python=${1:-python3}
            [[ $# -gt 0 ]] && shift
            unset PYTHONHOME
            if [[ -n $VIRTUAL_ENV ]]; then
                VIRTUAL_ENV=$(realpath "${VIRTUAL_ENV}")
            else
                local python_version
                python_version=$("$python" -c "import platform; print(platform.python_version())")
                if [[ -z $python_version ]]; then
                    log_error "Could not detect Python version"
                    return 1
                fi
                VIRTUAL_ENV=$PWD/.direnv/python-venv-$python_version
            fi
            export VIRTUAL_ENV
            if [[ ! -d $VIRTUAL_ENV ]]; then
                log_status "no venv found; creating $VIRTUAL_ENV"
                "$python" -m venv "$VIRTUAL_ENV"
            fi

            PATH="${VIRTUAL_ENV}/bin:${PATH}"
            export PATH
        }

#. Example `.envrc` file used in project directory. Need to make sure that each release root has this unique file. 

    .. code:: sh

        # Open edX named release project directory root.
        ## <project-path>/devstack.juniper/.envrc

        # https://discuss.openedx.org/t/docker-devstack-multiple-releases-one-machine/1902/10

        # This is handled when OPENEDX_RELEASE is set. Leaving this in for manual override.
        # export COMPOSE_PROJECT_NAME=devstack-juniper

        export DEVSTACK_WORKSPACE="$(pwd)"
        export OPENEDX_RELEASE=juniper.master
        export VIRTUAL_ENV="$(pwd)/devstack/venv"

        # https://github.com/direnv/direnv/wiki/Python#virtualenv
        layout python-venv

How do I create relational database dumps?
------------------------------------------
We use relational database dumps to spend less time running relational database
migrations and to speed up the provisioning of a devstack. These dumps are saved
as .sql scripts in the root directory of this git repository and they should be
updated occasionally - when relational database migrations take a prolonged amount
of time *or* we want to incorporate database schema changes which were done manually.

To update the relational database dumps:

1. Backup the data of your existing devstack if needed
2. If you are unsure whether the django_migrations tables (which keeps which migrations
were already applied) in each database are consistent with the existing database dumps,
disable the loading of these database dumps during provisioning by commenting out
the calls to ``load-db.sh`` in the provision-*.sh scripts. This ensures a start with a
completely fresh database and incorporates any changes that may have required some form
of manual intervention for existing installations (e.g. drop/move tables).
3. Run the shell script which destroys any existing devstack, creates a new one
and updates the relational database dumps:

.. code:: sh

   ./update-dbs-init-sql-scripts.sh

How do I keep my database up to date?
-------------------------------------

You can run Django migrations as normal to apply any changes recently made
to the database schema for a particular service.  For example, to run
migrations for LMS, enter a shell via ``make lms-shell`` and then run:

.. code:: sh

   paver update_db

Alternatively, you can discard and rebuild the entire database for all
devstack services by re-running ``make dev.provision`` or
``make dev.sync.provision`` as appropriate for your configuration.  Note that
if your branch has fallen significantly behind master, it may not include all
of the migrations included in the database dump used by provisioning.  In these
cases, it's usually best to first rebase the branch onto master to
get the missing migrations.

How do I access a database shell?
---------------------------------

To access a MySQL or Mongo shell, run the following commands, respectively:

.. code:: sh

   make mysql-shell
   mysql

.. code:: sh

   make mongo-shell
   mongo

How do I make migrations?
-------------------------

Log into the LMS shell, source the ``edxapp`` virtualenv, and run the
``makemigrations`` command with the ``devstack_docker`` settings:

.. code:: sh

   make lms-shell
   source /edx/app/edxapp/edxapp_env
   cd /edx/app/edxapp/edx-platform
   ./manage.py <lms/cms> makemigrations <appname> --settings=devstack_docker

Also, make sure you are aware of the `Django Migration Don'ts`_ as the
edx-platform is deployed using the red-black method.


How do I upgrade Node.JS packages?
----------------------------------

JavaScript packages for Node.js are installed into the ``node_modules``
directory of the local git repository checkout which is synced into the
corresponding Docker container.  Hence these can be upgraded via any of the
usual methods for that service (``npm install``,
``paver install_node_prereqs``, etc.), and the changes will persist between
container restarts.

How do I upgrade Python packages?
---------------------------------

Unlike the ``node_modules`` directory, the ``virtualenv`` used to run Python
code in a Docker container only exists inside that container.  Changes made to
a container's filesystem are not saved when the container exits, so if you
manually install or upgrade Python packages in a container (via
``pip install``, ``paver install_python_prereqs``, etc.), they will no
longer be present if you restart the container.  (Devstack Docker containers
lose changes made to the filesystem when you reboot your computer, run
``make down``, restart or upgrade Docker itself, etc.) If you want to ensure
that your new or upgraded packages are present in the container every time it
starts, you have a few options:

* Merge your updated requirements files and wait for a new `edxops Docker image`_
  for that service to be built and uploaded to `Docker Hub`_.  You can
  then download and use the updated image (for example, via ``make dev.pull.<service>``).
  The discovery and edxapp images are built automatically via a Jenkins job. All other
  images are currently built as needed by edX employees, but will soon be built
  automatically on a regular basis. See `How do I build images?`_
  for more information.
* You can update your requirements files as appropriate and then build your
  own updated image for the service as described above, tagging it such that
  ``docker-compose`` will use it instead of the last image you downloaded.
  (Alternatively, you can temporarily edit ``docker-compose.yml`` to replace
  the ``image`` entry for that service with the ID of your new image.) You
  should be sure to modify the variable override for the version of the
  application code used for building the image. See `How do I build images?`_.
  for more information.
* You can temporarily modify the main service command in
  ``docker-compose.yml`` to first install your new package(s) each time the
  container is started.  For example, the part of the studio command which
  reads ``...&& while true; do...`` could be changed to
  ``...&& pip install my-new-package && while true; do...``.
* In order to work on locally pip-installed repos like edx-ora2, first clone
  them into ``../src`` (relative to this directory). Then, inside your lms shell,
  you can ``pip install -e /edx/src/edx-ora2``. If you want to keep this code
  installed across stop/starts, modify ``docker-compose.yml`` as mentioned
  above.

How do I rebuild static assets?
-------------------------------

Optimized static assets are built for all the Open edX services during
provisioning, but you may want to rebuild them for a particular service
after changing some files without re-provisioning the entire devstack.  To
do this, run the make target for the appropriate service.  For example:

.. code:: sh

   make credentials-static

To rebuild static assets for all service containers:

.. code:: sh

   make static

How do I connect to the databases from an outside editor?
---------------------------------------------------------

To connect to the databases from an outside editor (such as MySQLWorkbench),
first uncomment these lines from ``docker-compose.yml``'s ``mysql`` section:

.. code-block::

  ports:
    - "3506:3306"

Then connect using the values below. Note that the username and password will
vary depending on the database. For all of the options, see ``provision.sql``.

- Host: ``localhost``
- Port: ``3506``
- Username: ``edxapp001``
- Password: ``password``

If you have trouble connecting, ensure the port was mapped successfully by
running ``docker-compose ps`` and looking for a line like this:
``edx.devstack.mysql docker-entrypoint.sh mysql ... Up 0.0.0.0:3506???3306/tcp``.

Switching branches
------------------

You can usually switch branches on a service's repository without adverse
effects on a running container for it.  The service in each container is
using runserver and should automatically reload when any changes are made
to the code on disk.  However, note the points made above regarding
database migrations and package updates.

When switching to a branch which differs greatly from the one you've been
working on (especially if the new branch is more recent), you may wish to
halt the existing containers via ``make down``, pull the latest Docker
images via ``make dev.pull.<service>``, and then re-run ``make dev.provision`` or
``make dev.sync.provision`` in order to recreate up-to-date databases,
static assets, etc.

If making a patch to a named release, you should pull and use Docker images
which were tagged for that release.

Changing LMS/CMS settings
-------------------------
The LMS and CMS read many configuration settings from the container filesystem
in the following locations:

- ``/edx/app/edxapp/lms.env.json``
- ``/edx/app/edxapp/lms.auth.json``
- ``/edx/app/edxapp/cms.env.json``
- ``/edx/app/edxapp/cms.auth.json``

Changes to these files will *not* persist over a container restart, as they
are part of the layered container filesystem and not a mounted volume. However, you
may need to change these settings and then have the LMS or CMS pick up the changes.

To restart the LMS/CMS process without restarting the container, kill the LMS or CMS
process and the watcher process will restart the process within the container. You can
kill the needed processes from a shell within the LMS/CMS container with a single line of bash script:

LMS:

.. code:: sh

    kill -9 $(ps aux | grep 'manage.py lms' | egrep -v 'while|grep' | awk '{print $2}')

CMS:

.. code:: sh

    kill -9 $(ps aux | grep 'manage.py cms' | egrep -v 'while|grep' | awk '{print $2}')

From your host machine, you can also run ``make lms-restart`` or
``make studio-restart`` which run those commands in the containers for you.

PyCharm Integration
-------------------

See the `Pycharm Integration documentation`_.

devpi Caching
-------------

LMS and Studio use a devpi container to cache PyPI dependencies, which speeds up several Devstack operations.
See the `devpi documentation`_.

Debugging using PDB
-------------------

It's possible to debug any of the containers' Python services using PDB. To do so,
start up the containers as usual with:

.. code:: sh

    make dev.up

This command starts each relevant container with the equivalent of the '--it' option,
allowing a developer to attach to the process once the process is up and running.

To attach to a container and its process, use ``make <service>-attach``. For example:

.. code:: sh

    make lms-attach

Set a PDB breakpoint anywhere in the code using:

.. code:: sh

    import pdb;pdb.set_trace()

and your attached session will offer an interactive PDB prompt when the breakpoint is hit.

To detach from the container, you'll need to stop the container with:

.. code:: sh

    make stop

or a manual Docker command to bring down the container:

.. code:: sh

   docker kill $(docker ps -a -q --filter="name=edx.devstack.<container name>")

Alternatively, some terminals allow detachment from a running container with the
``Ctrl-P, Ctrl-Q`` key sequence.

Running LMS and Studio Tests
----------------------------

After entering a shell for the appropriate service via ``make lms-shell`` or
``make studio-shell``, you can run any of the usual paver commands from the
`edx-platform testing documentation`_.  Examples:

.. code:: sh

    paver run_quality
    paver test_a11y
    paver test_bokchoy
    paver test_js
    paver test_lib
    paver test_python

Tests can also be run individually. Example:

.. code:: sh

    pytest openedx/core/djangoapps/user_api

Tests can also be easily run with a shortcut from the host machine,
so that you maintain your command history:

.. code:: sh

    ./in lms pytest openedx/core/djangoapps/user_api

Connecting to Browser
~~~~~~~~~~~~~~~~~~~~~

If you want to see the browser being automated for JavaScript or bok-choy tests,
you can connect to the container running it via VNC.

+------------------------+----------------------+
| Browser                | VNC connection       |
+========================+======================+
| Firefox (Default)      | vnc://0.0.0.0:25900  |
+------------------------+----------------------+
| Chrome (via Selenium)  | vnc://0.0.0.0:15900  |
+------------------------+----------------------+

On macOS, enter the VNC connection string in the address bar in Safari to
connect via VNC. The VNC passwords for both browsers are randomly generated and
logged at container startup, and can be found by running ``make vnc-passwords``.

Most tests are run in Firefox by default.  To use Chrome for tests that normally
use Firefox instead, prefix the test command with
``SELENIUM_BROWSER=chrome SELENIUM_HOST=edx.devstack.chrome``.

Running End-to-End Tests
------------------------

To run the base set of end-to-end tests for edx-platform, run the following
make target:

.. code:: sh

   make e2e-tests

If you want to use some of the other testing options described in the
`edx-e2e-tests README`_, you can instead start a shell for the e2e container
and run the tests manually via paver:

.. code:: sh

    make e2e-shell
    paver e2e_test --exclude="whitelabel\|enterprise"

The browser running the tests can be seen and interacted with via VNC as
described above (Firefox is used by default).

Troubleshooting: General Tips
-----------------------------

If you are having trouble with your containers, this sections contains some troubleshooting tips.

Check the logs
~~~~~~~~~~~~~~

If a container stops unexpectedly, you can look at its logs for clues::

    docker-compose logs lms

Update the code and images
~~~~~~~~~~~~~~~~~~~~~~~~~~

Make sure you have the latest code and Docker images.

Pull the latest Docker images by running the following command from the devstack
directory:

.. code:: sh

   make dev.pull

Pull the latest Docker Compose configuration and provisioning scripts by running
the following command from the devstack directory:

.. code:: sh

   git pull

Lastly, the images are built from the master branches of the application
repositories (e.g. edx-platform, ecommerce, etc.). Make sure you are using the
latest code from the master branches, or have rebased your branches on master.

Clean the containers
~~~~~~~~~~~~~~~~~~~~

Sometimes containers end up in strange states and need to be rebuilt. Run
``make down`` to remove all containers and networks. This will **NOT** remove your
data volumes.

Reset
~~~~~

Sometimes you just aren't sure what's wrong, if you would like to hit the reset button
run ``make dev.reset``.

Running this command will perform the following steps:

* Bring down all containers
* Reset all git repositories to the HEAD of master
* Pull new images for all services
* Compile static assets for all services
* Run migrations for all services

It's good to run this before asking for help.

Start over
~~~~~~~~~~

If you want to completely start over, run ``make destroy``. This will remove
all containers, networks, AND data volumes.

Resetting a database
~~~~~~~~~~~~~~~~~~~~

In case you botched a migration or just want to start with a clean database.

1. Open up the mysql shell and drop the database for the desired service::

    make mysql-shell
    mysql
    DROP DATABASE (insert database here)

2. From your devstack directory, run the provision script for the service. The
   provision script should handle populating data such as Oauth clients and
   Open edX users and running migrations::

    ./provision-(service_name)


Troubleshooting: Common issues
------------------------------

File ownership change
~~~~~~~~~~~~~~~~~~~~~

If you notice that the ownership of some (maybe all) files have changed and you
need to enter your root password when editing a file, you might
have pulled changes to the remote repository from within a container. While running
``git pull``, git changes the owner of the files that you pull to the user that runs
that command. Within a container, that is the root user - so git operations
should be ran outside of the container.

To fix this situation, change the owner back to yourself outside of the container by running:

.. code:: sh

  $ sudo chown <user>:<group> -R .

Running LMS commands within a container
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Most of the ``paver`` commands require a settings flag. If omitted, the flag defaults to
``devstack``. If you run into issues running ``paver`` commands in a docker container, you should append
the ``devstack_docker`` flag. For example:

.. code:: sh

  $ paver update_assets --settings=devstack_docker

Resource busy or locked
~~~~~~~~~~~~~~~~~~~~~~~

While running ``make static`` within the ecommerce container you could get an error
saying:

.. code:: sh

  Error: Error: EBUSY: resource busy or locked, rmdir '/edx/app/ecommerce/ecommerce/ecommerce/static/build/'

To fix this, remove the directory manually outside of the container and run the command again.

No space left on device
~~~~~~~~~~~~~~~~~~~~~~~

If you see the error ``no space left on device`` on a Mac, Docker has run
out of space in its Docker.qcow2 file.

Here is an example error while running ``make dev.pull``:

.. code:: sh

   ...
   32d52c166025: Extracting [==================================================>] 1.598 GB/1.598 GB
   ERROR: failed to register layer: Error processing tar file(exit status 1): write /edx/app/edxapp/edx-platform/.git/objects/pack/pack-4ff9873be2ca8ab77d4b0b302249676a37b3cd4b.pack: no space left on device
   make: *** [pull] Error 1

Try this first to clean up dangling images:

.. code:: sh

   docker image prune -f  # (This is very safe, so try this first.)

If you are still seeing issues, you can try cleaning up dangling volumes.

**Warning**: In most cases this will only remove volumes you no longer need, but
this is not a guarantee.

.. code:: sh

   docker volume prune -f  # (Be careful, this will remove your persistent data!)


No such file or directory
~~~~~~~~~~~~~~~~~~~~~~~~~

While provisioning, some have seen the following error:

.. code:: sh

   ...
   cwd = os.getcwdu()
   OSError: [Errno 2] No such file or directory
   make: *** [dev.provision.services] Error 1

This issue can be worked around, but there's no guaranteed method to do so.
Rebooting and restarting Docker does *not* seem to correct the issue. It
may be an issue that is exacerbated by our use of sync (which typically speeds
up the provisioning process on Mac), so you can try the following:

.. code:: sh

   # repeat the following until you get past the error.
   make stop
   make dev.provision

Once you get past the issue, you should be able to continue to use sync versions
of the make targets.

Memory Limit
~~~~~~~~~~~~

While provisioning, some have seen the following error:

.. code:: sh

   ...
   Build failed running pavelib.assets.update_assets: Subprocess return code: 137

This error is an indication that your docker process died during execution.  Most likely,
this error is due to running out of memory.  Try increasing the memory
allocated to Docker.

Docker is using lots of CPU time when it should be idle
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On the Mac, this often manifests as the ``hyperkit`` process using a high
percentage of available CPU resources.  To identify the container(s)
responsible for the CPU usage:

.. code:: sh

    make stats

Once you've identified a container using too much CPU time, check its logs;
for example:

.. code:: sh

    make lms-logs

The most common culprit is an infinite restart loop where an error during
service startup causes the process to exit, but we've configured
``docker-compose`` to immediately try starting it again (so the container will
stay running long enough for you to use a shell to investigate and fix the
problem).  Make sure the set of packages installed in the container matches
what your current code branch expects; you may need to rerun ``pip`` on a
requirements file or pull new container images that already have the required
package versions installed.

Performance
-----------

Improve Mac OSX Performance with docker-sync
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Docker for Mac has known filesystem issues that significantly decrease
performance for certain use cases, for example running tests in edx-platform. To
improve performance, `Docker Sync`_  can be used to synchronize file data from
the host machine to the containers.

Many developers have opted not to use `Docker Sync`_ because it adds complexity
and can sometimes lead to issues with the filesystem getting out of sync.

You can swap between using Docker Sync and native volumes at any time, by using
the make targets with or without 'sync'. However, this is harder to do quickly
if you want to switch inside the PyCharm IDE due to its need to rebuild its
cache of the containers' virtual environments.

If you are using macOS, please follow the `Docker Sync installation
instructions`_ before provisioning.

Docker Sync Troubleshooting tips
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Check your version and make sure you are running 0.4.6 or above:

.. code:: sh

    docker-sync --version

If not, upgrade to the latest version:

.. code:: sh

    gem update docker-sync

If you are having issues with docker sync, try the following:

.. code:: sh

    make stop
    docker-sync stop
    docker-sync clean

Cached Consistency Mode
~~~~~~~~~~~~~~~~~~~~~~~

The performance improvements provided by `cached consistency mode for volume
mounts`_ introduced in Docker CE Edge 17.04 are still not good enough. It's
possible that the "delegated" consistency mode will be enough to no longer need
docker-sync, but this feature hasn't been fully implemented yet (as of
Docker 17.12.0-ce, "delegated" behaves the same as "cached").  There is a
GitHub issue which explains the `current status of implementing delegated consistency mode`_.

.. _Docker Compose: https://docs.docker.com/compose/
.. _Docker for Mac: https://docs.docker.com/docker-for-mac/
.. _Docker for Windows: https://docs.docker.com/docker-for-windows/
.. _Docker Sync: https://github.com/EugenMayer/docker-sync/wiki
.. _Docker Sync installation instructions: https://github.com/EugenMayer/docker-sync/wiki/1.-Installation
.. _cached consistency mode for volume mounts: https://docs.docker.com/docker-for-mac/osxfs-caching/
.. _current status of implementing delegated consistency mode: https://github.com/docker/for-mac/issues/1592
.. _configuring Docker for Mac: https://docs.docker.com/docker-for-mac/#/advanced
.. _feature added in Docker 17.05: https://github.com/edx/configuration/pull/3864
.. _edx-e2e-tests README: https://github.com/edx/edx-e2e-tests/#how-to-run-lms-and-studio-tests
.. _edxops Docker image: https://hub.docker.com/r/edxops/
.. _Docker Hub: https://hub.docker.com/
.. _Pycharm Integration documentation: docs/pycharm_integration.rst
.. _devpi documentation: docs/devpi.rst
.. _edx-platform testing documentation: https://github.com/edx/edx-platform/blob/master/docs/guides/testing/testing.rst#running-python-unit-tests
.. _docker-sync: #improve-mac-osx-performance-with-docker-sync
.. |Build Status| image:: https://travis-ci.org/edx/devstack.svg?branch=master
    :target: https://travis-ci.org/edx/devstack
    :alt: Travis
.. _Docker CI Jenkins Jobs: https://tools-edx-jenkins.edx.org/job/DockerCI
.. _How do I build images?: https://github.com/edx/devstack/tree/master#how-do-i-build-images
   :target: https://travis-ci.org/edx/devstack
.. _Django Migration Don'ts: https://engineering.edx.org/django-migration-donts-f4588fd11b64
.. _Python virtualenv: http://docs.python-guide.org/en/latest/dev/virtualenvs/#lower-level-virtualenv
.. _Running analytics acceptance tests in docker: http://edx-analytics-pipeline-reference.readthedocs.io/en/latest/running_acceptance_tests_in_docker.html
.. _Troubleshooting docker analyticstack: http://edx-analytics-pipeline-reference.readthedocs.io/en/latest/troubleshooting_docker_analyticstack.html
.. _Community: https://open.edx.org/community/connect/


NAU notes
-----------

.. code:: sh

    sysctl -w fs.inotify.max_user_watches=30000


