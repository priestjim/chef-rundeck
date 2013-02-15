# Package
default['rundeck']['version'] = '1.4.5-1'
default['rundeck']['deb_url'] = "http://download.rundeck.org/deb/rundeck-#{node['rundeck']['version']}.deb"
default['rundeck']['deb_checksum'] = '658f0cf61f23e02cb9a6506ba6b637cc2d557bc40b4a3fc8b19bb143f5e0bea2'
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
default['rundeck']['ssh']['timeout'] = 30000
default['rundeck']['ssh']['port'] = 22

default['rundeck']['chef']['port'] = 9998
