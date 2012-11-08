# Package
default['rundeck']['version'] = '1.4.4-1'
default['rundeck']['deb_url'] = "https://github.com/downloads/dtolabs/rundeck/rundeck-#{node['rundeck']['version']}.deb"
default['rundeck']['deb_checksum'] = '16fb6f7995d42860976f9542c5e5a1bba8f3b9bfd515135056ff3181fcfc6ead'
default['rundeck']['rpm_url'] = 'http://repo.rundeck.org/latest.rpm'

# Framework configuration

default['rundeck']['node_name'] = node.name

default['rundeck']['mail'] = {
	'hostname'		=> 'localhost',
	'port'     		=> 25,
	'username' 		=> nil,
	'password' 		=> nil,
	'from'     		=> 'ops@example.com',
	'tls'      		=> false
}

default['rundeck']['mail']['recipients_data_bag'] = 'users'
default['rundeck']['mail']['recipients_query'] = 'notify:true'
default['rundeck']['mail']['recipients_field'] = 'email'

default['rundeck']['admin']['data_bag'] = 'cookies'
default['rundeck']['admin']['data_bag_id'] = 'rundeck'

default['rundeck']['proxy']['hostname'] = 'rundeck'
default['rundeck']['proxy']['default'] = false

default['rundeck']['ssh']['user'] = 'rundeck-ssh'
default['rundeck']['ssh']['timeout'] = 30

default['rundeck']['chef']['port'] = 9998
