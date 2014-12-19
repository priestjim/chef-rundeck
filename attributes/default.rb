#
# Cookbook Name:: rundeck
# Attribute:: default
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2013, Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Package
default['rundeck']['deb_version']       = '2.4.0-1-GA'
default['rundeck']['deb_url']           = "http://dl.bintray.com/rundeck/rundeck-deb/rundeck-#{node['rundeck']['deb_version']}.deb"
default['rundeck']['deb_checksum']      = '8686aee8a53d01cd221e60cca86882f008cec356bfa931b9baa707a6cf9265f6'

default['rundeck']['rpm_version']       = '2.4.0-1.1.GA'
default['rundeck']['rpm_url']           = "http://download.rundeck.org/rpm/rundeck-#{node['rundeck']['rpm_version']}.noarch.rpm"
default['rundeck']['rpm_cfg_url']       = "http://download.rundeck.org/rpm/rundeck-config-#{node['rundeck']['rpm_version']}.noarch.rpm"
default['rundeck']['rpm_checksum']      = '3909730d0141abd196368a8dfe9e5ed72007fc32716fb0f44cec54b0dcd9d589'
default['rundeck']['rpm_cfg_checksum']  = '4932c04d2f4b1e15d644bea69482d78166240cddf8def19f11f3365a0e48be19'

# Framework configuration
default['rundeck']['node_name']         = node.name
default['rundeck']['hostname']          = node['fqdn']
default['rundeck']['port']              = 4440
default['rundeck']['url']               = "http://#{node['rundeck']['hostname']}:#{node['rundeck']['port']}"
default['rundeck']['log4j_port']        = 4435
default['rundeck']['public_rss']        = false
default['rundeck']['logging_level']     = 'INFO'
default['rundeck']['partial_search']    = true

# Authentication Configuration - Used to configure the profile file in /etc/rundeck when ldap or similar auth method
default['rundeck']['authentication']['file']  = 'jaas-loginmodule.conf'
default['rundeck']['authentication']['name']  = 'RDpropertyfilelogin'

# Stub config files
default['rundeck']['stub_config_files'] = %w{ log4j.properties jaas-loginmodule.conf apitoken.aclpolicy admin.aclpolicy }

# Administrator data bag
default['rundeck']['admin']['encrypted_data_bag'] = true
default['rundeck']['admin']['data_bag']           = 'credentials'
default['rundeck']['admin']['data_bag_id']        = 'rundeck'
# For Solo runs with no data bags
default['rundeck']['admin']['username']           = 'admin'
default['rundeck']['admin']['password']           = 'a73e319b433528eaa646' # Override this!
default['rundeck']['admin']['ssh_key']            = ''


# Mail data bag
default['rundeck']['mail']          = {
	'hostname'		=> 'localhost',
	'port'     		=> 25,
	'username' 		=> nil,
	'password' 		=> nil,
	'from'     		=> 'ops@example.com',
	'tls'      		=> false
}
default['rundeck']['mail']['recipients_data_bag'] = 'users'
default['rundeck']['mail']['recipients_query']    = 'notify:true'
default['rundeck']['mail']['recipients_keys']     = { 'email' => ['email'] }
default['rundeck']['mail']['recipients_field']    = "['email']"

# External Database properties
default['rundeck']['rdbms']['enable'] = false

# Support mysql otherwise Oracle
default['rundeck']['rdbms']['type'] = "mysql"
default['rundeck']['rdbms']['location'] = "localhost"
default['rundeck']['rdbms']['dbname'] = "rundeckdb"
default['rundeck']['rdbms']['dbuser'] = "rundeckdb"
default['rundeck']['rdbms']['dbpassword'] = "password"
default['rundeck']['rdbms']['dialect'] = "Oracle10gDialect"
default['rundeck']['rdbms']['port'] = "3306"
