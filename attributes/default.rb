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
default['rundeck']['deb_version']       = '2.0.1-1-GA'
default['rundeck']['deb_url']           = "http://download.rundeck.org/deb/rundeck-#{node['rundeck']['deb_version']}.deb"
default['rundeck']['deb_checksum']      = 'aaa183196c6d94d435ca4361b1eda5e8f40676bd6a2248072a90553aef147811'

default['rundeck']['rpm_version']       = '2.0.1-1.9.GA'
default['rundeck']['rpm_url']           = "http://download.rundeck.org/rpm/rundeck-#{node['rundeck']['rpm_version']}.noarch.rpm"
default['rundeck']['rpm_cfg_url']       = "http://download.rundeck.org/rpm/rundeck-config-#{node['rundeck']['rpm_version']}.noarch.rpm"
default['rundeck']['rpm_checksum']      = '6192f035e80731cf8efc39f30479601a73f76d2a85db471c182e8afeb5d6b632'
default['rundeck']['rpm_cfg_checksum']  = 'c5bb61f5b5464b37c578a44ea86e168ea23cb73be6de7a5ee7cf5c895fae9c5a'

# Framework configuration
default['rundeck']['node_name']         = node.name
default['rundeck']['hostname']          = node['fqdn']
default['rundeck']['port']              = 4440
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
