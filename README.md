chef-rundeck
============

This is a Chef cookbook for the remote administration tool [Rundeck](http://rundeck.org). It installs the Rundeck
package (either on deb or rpm format) and configures various aspects of the software.

The latest and greatest revision of this cookbook will always be available
at https://github.com/priestjim/chef-rundeck

Requirements
============

Cookbooks
---------

The following cookbooks are direct dependencies because they're used
for common "default" functionality.

* java
* apt
* yum
* logrotate

In order to install the Chef discovery service, you'll need the `supervisor`
cookbook.

In order to install the NGINX proxy site, you'll either need the `openresty` or
`nginx` cookbook.

Platform
--------

The following platforms are supported and tested using Vagrant 1.2:

* Ubuntu 12.04
* CentOS 6.4

Other Debian and RHEL family distributions are assumed to work.

Chef Server
-----------

The cookbook converges best on Chef installations >= 10.18.2

Attributes
==========

Attributes are split in files semantically:

## default.rb

* `node['rundeck']['deb_version']` - The Rundeck version to be installed for Debian-based distributions.

* `node['rundeck']['rpm_version']` - The Rundeck version to be installed for RPM-based distributions.

* `node['rundeck']['node_name']` - The Rundeck node name. Defaults to `node.name`

* `node['rundeck']['url']` - The URL that Rundeck will be running on. Change it if you're running it over a reverse proxy.

* `node['rundeck']['hostname']` - The hostname Rundeck servers from.

* `node['rundeck']['port']` - The port Rundeck HTTP server runs on.

* `node['rundeck']['log4j_port']` - The Rundeck Log4J port.

* `node['rundeck']['public_rss']` - Enables an unauthenticated RSS feed for jobs.

* `node['rundeck']['logging_level']` - The default logging level for Rundeck.

* `node['rundeck']['authentication']['file']` - The default authentication file to use for rundeck profile.

* `node['rundeck']['authentication']['name']` - The default authentication name to use for rundeck profile.

* `node['rundeck']['stub_config_files']` - The default rundeck stub config files.  These may need to be configured by a wrapper cookbook so overriding this value to remove the files your wrapper cookbook manages is the desired usecase.

* `node['rundeck']['admin']['encrypted_data_bag']` - Enables loading the Rundeck administrator
  credentials using Chef encrypted data bags instead of simple ones.

* `node['rundeck']['admin']['data_bag']` - The data bag name for the administrator credentials.

* `node['rundeck']['admin']['data_bag_id']` - The data bag item name for the administrator credentials.

* `node['rundeck']['admin']['username']` - Hardcoded administrator username in case data bags are not
  available (i.e. chef-solo runs).

* `node['rundeck']['admin']['password']` - Hardcoded administrator password in case data bags are not
  available (i.e. chef-solo runs).

* `node['rundeck']['admin']['ssh_key']` - Hardcoded administrator private SSH key in case data bags are not
  available (i.e. chef-solo runs).

* `node['rundeck']['partial_search']` - Enables partial search support for mail credentials.

* `node['rundeck']['mail']` - Hash with various SMTP parameters used by Rundeck for notifications.

* `node['rundeck']['mail']['recipients_data_bag']` - The name of the data bag to be searched for recipients
  of mails for administrative purposes.

* `node['rundeck']['mail']['recipients_keys']` - A partial search compatible hash with the fields and the field paths
to run the partial_search for.

* `node['rundeck']['mail']['recipients_query']` - A standard Chef query to use for searching for administrative
  contacts.

* `node['rundeck']['mail']['recipients_field']` - Field to use for the administrative e-mail. Must be in standard hash
  notation and will be eval'ed (i.e. "['email']")

* `node['rundeck']['rdbms']['enable']` - Enable external database. By default false, use internal hsqldb.
* `node['rundeck']['rdbms']['type']` - mysql or oracle. Defaults to "mysql"
* `node['rundeck']['rdbms']['location']` - Hostname of database. Defaults to "localhost"
* `node['rundeck']['rdbms']['dbname']` - Database name. Defaults to "rundeckdb"
* `node['rundeck']['rdbms']['dbuser']` - Database user. Defaults to "rundeckdb"
* `node['rundeck']['rdbms']['dbpassword']` - Database password. Defaults to "password"
* `node['rundeck']['rdbms']['dialect']` - Hibernate dialect. Only used when type is oracle. Defaults to "Oracle10gDialect"

* `node['rundeck']['custom_properties']['framework']` - Key/value pairs of custom properties present in framework.properties
* `node['rundeck']['custom_properties']['project']` = Key/value pairs of custom properties present in project.properties

## chef.rb

* `node['rundeck']['chef']['port']` - TCP port to run the chef-rundeck discovery service

* `node['rundeck']['chef']['client_key']` - Hardcoded Chef client key in case data bags are not available

* `node['rundeck']['chef']['port']` - Hardcoded Chef client name in case data bags are not available

* `node['rundeck']['chef']['partial_search']` - Enable partial search support on the chef-rundeck gem

* `node['rundeck']['chef']['cache_timeout']` - Sets the time chef-rundeck will cache the Chef server results, in seconds

* `node['rundeck']['chef']['ssl_verify_mode']` - Sets the verify mode of the SSL connection to the Chef server

* `node['rundeck']['chef']['server_url']` - Chef Server URL to query for nodes to build Rundeck's [resources model](http://rundeck.org/docs/man5/resource-xml.html#node). Defaults to `Chef::Config['chef_server_url']`

## ssh.rb

* `node['rundeck']['ssh']['user']` - Default SSH user with whom Rundeck will login to the servers.

* `node['rundeck']['ssh']['timeout']` - SSH connection timeout in milliseconds.

* `node['rundeck']['ssh']['port']` - Default SSH port to connect to.

## java.rb

* `node['java']['jdk_version']` - Sets the version of jdk, defaults to `7`

* `node['rundeck']['java']['enable_jmx']` - Defines a set of flags in order to enable JMX monitoring on the
  Rundeck installation

* `node['rundeck']['java']['allocated_memory']` - Defines the maximum heap memory available to Rundeck's JVM

* `node['rundeck']['java']['thread_stack_size']` - Defines the default thread stack size for the Rundeck's JVM

* `node['rundeck']['java']['perm_gen_size']` - Defines the permanent generation size for the Rundeck's JVM

## proxy.rb

* `node['rundeck']['proxy']['hostname']` - Defines the default hostname used in the NGINX proxy instance.

* `node['rundeck']['proxy']['default']` - Set to true to enable the NGINX default server flags for the Rundeck
  proxy virtual host.

Recipes
=======

## default.rb

The `default` recipe will install the official Rundeck package for your specific distribution and install various
configuration files needed for Rundeck to operate. If you need SSL support, it would be better to use a reverse proxy for
this (such us NGINX or Apache2) since Rundeck's SSL support requires various complicated steps (all hail Java).

Log rotation of Rundeck's and Chef-Rundeck's logs is managed by a `logrotate` job.

The `default` recipe will install and enable either a SYSV-standard service for Redhat and Debian based distributions
or an Upstart service for Ubuntu installations.

The cookbook also needs a custom Rundeck user that will be used to execute remote jobs. You need to create the user before
installing Rundeck and then define a passwordless RSA SSH key for the user in this cookbook's properties.

All credentials used are retrieved from:

* An encrypted data bag if the `node['rundeck']['admin']['encrypted_data_bag']` attribute is enabled
* A simple data bag otherwise
* In case there is no data bag defined, administrative attributes are retrieved from node attributes

## chef.rb

The `chef` recipe will install the `chef-rundeck` gem using the Ruby bundled with the Chef omnibus package. That way, no
extra dependencies occur (i.e. rbenv or rvm or a packaged ruby).

Supervisor from the `supervisor` cookbook is used to start and supervise the service.

As with `default`, all credentials (Chef client key and client name) used are retrieved from:

* An encrypted data bag if the `node['rundeck']['admin']['encrypted_data_bag']` attribute is enabled
* A simple data bag otherwise
* In case there is no data bag defined, administrative attributes are retrieved from node attributes

## proxy.rb

The `proxy` recipe will install an NGINX configuration file that exposes Rundeck through a reverse proxy HTTP interface.

Data bag format
===============

The Rundeck cookbook requires some data to be available in data bags. Depending on the value of
`node['rundeck']['admin']['encrypted_data_bag']`, the data bag data will be loaded via encrypted data bag
methods or plain. You can select the data bag name and ID via the `node['rundeck']['admin']['data_bag']`
and `node['rundeck']['admin']['data_bag_id']` attributes. The following attributes must be present in the
selected data bag:

* `username`: Used as the default administrator's username created during the initial installation of Rundeck.
* `password`: Used the default administrator's password created during the initial installation of Rundeck.
* `ssh_key`: Used in place of the Rundeck SSH user's RSA private key.

If you are using the `rundeck::chef` recipe, the following must be present in the data bag too:

* `client_key`: The Chef client's private key in PEM format.
* `client_name`: The Chef client's name.

In addition to administrative attributes, data bags are used in mail recipient search. The search query searches among the
`node['rundeck']['mail']['recipients_data_bag']` data bag using a standard Chef query defined in
`node['rundeck']['mail']['recipients_query']` and from the results retrieves the field
defined in `node['rundeck']['mail']['recipients_field']` using standard Ruby eval.
So, if you are looking for the `user['notifications']['email']` field in your data bags
for your mail recipients, you should define it as:

    node['rundeck']['mail']['recipients_field'] = "['notifications']['email']"

LWRP
====

## user

This cookbook defines the `rundeck_user` LWRP. The LWRP can be used to create users
in Rundeck (see http://rundeck.org/docs/administration/authentication.html#realm.properties) through the standard
`realm.properties` file. Only MD5 and CRYPT encryption is supported as an encryption scheme, along with plain-text.

The following actions are supported:

* `create` - Creates a Rundeck user if it does not exist already.
* `update` - Updates a Rundeck user.
* `delete` - Removes a Rundeck user.

The following attributes are used in the LWRP:

* `name` - The actual Rundeck username.
* `password` - The password in plain text.
* `roles` - The Rundeck roles that this user is a member of.
* `encryption` - One of `crypt`, `md5`, `plain`.

Usage sample:

    rundeck_user 'ops' do
      password '123abc'
      encryption 'md5'
      roles %w{ user admin architect deploy build }
      action :create
    end

## plugin

This cookbook defines the `rundeck_plugin` LWRP. The LWRP can be used to install plugins in Rundeck
(see http://rundeck.org/docs/plugins-user-guide/index.html). Plugin installation is fairly straight-forward as
plugins can be installed/uninstalled just by moving/removing the plugin file
from the `libext` directory in Rundeck's home.

The following actions are supported:

* `create` - Installs a Rundeck plugin.
* `remove` - Removes a Rundeck plugin.

The following attributes are used in the LWRP:

* `name` - The plugin name. Plugin must end in `.jar` or `.zip` to be considered valid.
* `url` - The URL to fetch the plugin from.
* `checksum` - SHA-256 checksum of the plugin. Used in the same way as the `remote_file` resource.

Usage sample:

    rundeck_plugin 'rundeck-hipchat-plugin-1.0.0.jar' do
      checksum 'd7fea03867011aa18ba5a5184aa1fb30befc59b8fbea5a76d88299abe05aec28'
      url 'http://search.maven.org/remotecontent?filepath=com/hbakkum/rundeck/plugins/rundeck-hipchat-plugin/1.0.0/rundeck-hipchat-plugin-1.0.0.jar'
    end

Usage
=====

Include the recipe on your node or role. Modify the
attributes as required in a role cookbook to change how various
configuration variables are applied per the attributes section above.
It is important the data bags are properly set up.  An example is given
below for the minimum requirements to converge this cookbook.

The default 'credentials' data bag:

```
{
   "id": "rundeck",
   "username": "admin",
   "password": "admin"
}
```

The default 'users' data bag:

```
{
   "id": "users"
}
```

If you need to alter the location of various cookbook_file
directives, use `chef_rewind`.

License and Author
==================

- Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)

Copyright 2013, Panagiotis Papadomitsos

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
