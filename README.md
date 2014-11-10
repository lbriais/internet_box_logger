# [InternetBoxLogger][IBL]

 [![Build Status](https://travis-ci.org/lbriais/internet_box_logger.svg)](https://travis-ci.org/lbriais/internet_box_logger)
 [![Gem Version](https://badge.fury.io/rb/internet_box_logger.svg)](http://badge.fury.io/rb/internet_box_logger)

## Overview

The goal of this [gem][IBL] is to provide an easy way to monitor your internet box status.
It primarily targets the box I am using (the Freebox V5 from the '[Free]' french ISP).

Currently supported box:

* **Freebox V5**

## Installation

### Dependencies

You need to have [ELK] installed, the fantastic software trilogy that brings you the power of analytics at your fingertips.
In our case we just need ElasticSearch and Kibana, LogStash is not needed, but you should not prevent yourself from
using it for log files of your own...

Follow [ELK] installation procedure before installing this Gem.

### Gem installation
Add this line to your application's Gemfile:

    gem 'internet_box_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install internet_box_logger

### Configuration

Configuration, thanks to [EasyAppHelper][EAP], enables multiple places to store your configuration. But most useful
ones should be:

* '`/etc/internet_box_logger.conf`' for a system-wide installation
* '`~/.config/internet_box_logger.conf`' for a user-specific installation

The default configuration is the following in YAML format:

```yaml
box_type: InternetBoxLogger::Parsers::FreeboxV5Parser

cron_interval: 1

kibana_path: /opt/kibana

server_port: 5000

default_elastic_search:
  elastic_servers:
    - 127.0.0.1:9200
  elastic_binary: /opt/elasticsearch/bin/elasticsearch
```

* `box_type` specifies the module in charge of gathering data from your box. it Should not be changed but you can define
your own. **It is the way for you to add other types of boxes** if needed. If you do so, please do a pull-request
afterwards.
* `cron_interval` defines the time in minutes between two measurements.
* `kibana_path` defines where your [Kibana][ELK] is installed. This one is only used by a rake task to setup default
dashboards for your box. This is not really needed for the script to work.
* `server_port` defines the port to run a simple HTTP server to serve the Kibana UI.
* `elastic_servers` You can specify here, how to reach your ElasticSearch cluster. If you did the default install of
ElasticSearch on the same machine as the gem is installed, then it should already be the correct host:port.
* `elastic_binary` defines where your [ElasticSearch][ELK] is installed. This one is only used by a rake task
(to stop/start and get info) about the ElasticSearch cluster. This is not really needed for the log process to work.
Only to enable stop/start of the server.
When you change it in your config, you do not need to set it in the `default_elastic_search` hash, but instead you can
directly set it at the root.

**These values are the default and you don't need to create a new config file if they already fit your needs.**
And it should be the case if you installed [ELK] as a whole on the machine you are using this gem.

You can deploy every component separately and in this case you nay have to tweak the configuration.

Most probably if you installed [ELK] locally, your config file may look like:

```yaml
kibana_path: <the_place_where_I_installed_Kibana>
elastic_binary: <the_path_to_the_elasticsearch_binary>
```

## Usage

This Gem brings basically an executable '```internet_box_logger```' that will save the state of your box into an
ElasticSearch instance.

The script supports the following options that you can see with the ```--help``` options:

```
-- Generic options -------------------------------------------------------------
        --auto                 Auto mode. Bypasses questions to user.
        --simulate             Do not perform the actual underlying actions.
    -v, --verbose              Enable verbose mode.
    -h, --help                 Displays this help.
-- Configuration options -------------------------------------------------------
        --config-file          Specify a config file.
        --config-override      If specified override all other config.
-- Debug and logging options ---------------------------------------------------
        --debug                Run in debug mode.
        --debug-on-err         Run in debug mode with output to stderr.
        --log-level            Log level from 0 to 5, default 2.
        --log-file             File to log to.
-- Script specific -------------------------------------------------------------
        --cron_interval        Specify the interval at which the measurements will be done
        --cron_remove          Remove the Cron task
        --cron_setup           Setup the Cron task
        --deploy_reports       Deploy boxes dashboards to Kibana default folder
        --es_start             Starts the ElasticSearch server if installed locally and properly configured
        --es_stop              Stops the ElasticSearch server if installed locally and properly configured
        --serve                Runs a simple web server to serve Kibana UI
        --server_port          Specify server port if you use the "--serve" option
```

On top of this the gem brings a set of rake tasks **in case you bundle this gem in your own project**.

The rake tasks provided are:

```
rake internet_box_logger:cron:info           # Show your Cron config
rake internet_box_logger:cron:remove         # Removes cron task
rake internet_box_logger:cron:setup          # Setup cron to gather information every x minutes (configurable)
rake internet_box_logger:es:info             # Show your local ElasticSearch config
rake internet_box_logger:es:start            # Starts your local ElasticSearch server
rake internet_box_logger:es:stop             # Stops your local ElasticSearch server
rake internet_box_logger:kibana:deploy       # Deploys box specific reports into Kibana dashboards directory
rake internet_box_logger:kibana:info         # Displays Kibana information
rake internet_box_logger:kibana:serve[port]  # Launch a simple server to serve Kibana UI
```

### Script vs rake mode

As stated, the [gem][IBL] supports two way to interact:

* The ```internet_box_logger``` script provided with the gem
* The rake tasks provided with the gem when you use it in your own projects

Most commands are actually same, and the following commands have the same effect:

<table>
    <tr>
        <td><pre>rake internet_box_logger:cron:setup</pre></td>
        <td><pre>internet_box_logger -v --cron-setup</pre></td>
    </tr>
    <tr>
        <td><pre>rake internet_box_logger:cron:remove</pre></td>
        <td><pre>internet_box_logger -v --cron-remove</pre></td>
    </tr>
    <tr>
        <td><pre>rake internet_box_logger:es:start</pre></td>
        <td><pre>internet_box_logger -v --es-start</pre></td>
    </tr>
    <tr>
        <td><pre>rake internet_box_logger:es:stop</pre></td>
        <td><pre>internet_box_logger -v --es-stop</pre></td>
    </tr>
    <tr>
        <td><pre>rake internet_box_logger:kibana:deploy</pre></td>
        <td><pre>internet_box_logger -v --deploy-reports</pre></td>
    </tr>
    <tr>
        <td><pre>rake internet_box_logger:kibana:serve</pre></td>
        <td><pre>internet_box_logger -v --serve</pre></td>
    </tr>
    <tr>
        <td><pre>rake internet_box_logger:kibana:serve[1234] (*)</pre></td>
        <td><pre>internet_box_logger -v --serve --server-port 1234</pre></td>
    </tr>
</table>

(\*) Warning, if you are using zsh, you may probably have to escape the brackets with backslashes.


### Starting to monitor your box

You have to have:

 * A running instance of ElasticSearch. If it is installed locally and the path to your ElasticSearch binary
 is correctly set in your config file, you can use the command line or the rake task (if you use this gem in your
 project) to start/stop it.
 * A place where kibana is installed
 * Setup correctly the `kibana_path` in your config and run either the the command line or the rake task (if you use
 this gem in your project) to deploy the reports to Kibana. Alternatively, you can manually copy the JSON files stored
 in the config/kibana_reports directory to where your Kibana is install in the  app/dashboards sub-directory.
 * An http server to serve the Kibana UI. You can use the mini embedded server and you can use the command line or the
 rake task (if you use this gem in your project) to start/stop it (a correctly defined `kibana_path` in your config is
 required). Alternatively you can serve it with a server of your own.
 * Setup the CRON task that will schedule the log into elastic search. You can use the command line or the rake task
 (if you use this gem in your project) to setup/remove the CRON task and you can verify it with `crontab -l`.
 Alternatively, you can create the cron entry fully manually or call the `internet_box_logger` from your own
 scheduler.

Then provided you started the embedded server you just need to navigate to:

   http://localhost:5000/#/dashboard/file/FreeboxV5_report.json

   This url is for the Freebox V5 which is the currently only one supported.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Basically, to contribute you may want to:

* create the module to gather information from your box.
* build the Kibana report to display information.
* Update the tests accordingly


That's all folks.


[IBL]:  https://rubygems.org/gems/internet_box_logger        "internet_box_logger gem"
[Free]: http://free.fr                                       "Free French ISP"
[ELK]:  http://www.elasticsearch.org/overview/elkdownloads/  "ElasticSearch, LogStash, Kibana"
[EAP]:  https://rubygems.org/gems/easy_app_helper            "EasyAppHelper gem"
