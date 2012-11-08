#
# Cookbook Name:: chef-rundeck
# Recipe:: chef
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

include_recipe 'supervisor'

adminobj = data_bag_item(node['rundeck']['admin']['data_bag'], node['rundeck']['admin']['data_bag_id'])

if adminobj['client_key'].nil? || adminobj['client_key'].empty? || adminobj['client_name'].nil? || adminobj['client_name'].empty?
	Chef::Log.info("Could not locate a valid client/PEM key pair for chef-rundeck. Please define one!")
	return true
end

# Install the chef-rundeck gem on the Chef omnibus package. Useful workaround instead of installing RVM, a system Ruby etc
# and it offers minimal system pollution
chef_gem 'chef-rundeck'

# Create the knife.rb for chef-rundck to read
directory "/var/lib/rundeck/.chef" do
	owner 'rundeck'
	group 'rundeck'
	mode 00755
	action :create
end

template "/var/lib/rundeck/.chef/knife.rb" do
	source "knife.rb.erb"
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	variables({
		:user => adminobj['client_name'],
		:chef_server_url => Chef::Config['chef_server_url']
	})
end

file "/var/lib/rundeck/.chef/#{adminobj['client_name']}.pem" do
	action :create
	owner 'rundeck'
	group 'rundeck'
	mode 00644
	content adminobj['client_key'].join("\n")
end

# Create a Supervisor service that runs chef-rundeck
supervisor_service "chef-rundeck" do
	command "/opt/chef/embedded/bin/chef-rundeck -c /var/lib/rundeck/.chef/knife.rb -u #{node['rundeck']['ssh']['user']} -w #{Chef::Config['chef_server_url']} -p #{node['rundeck']['chef']['port']}"
	numprocs 1
	directory "/var/lib/rundeck"
	autostart true
	autorestart :unexpected
	startsecs 15
	stopwaitsecs 15
	stdout_logfile '/var/log/rundeck/chef-rundeck.log'
	stdout_logfile_maxbytes "10MB"
	stdout_logfile_backups 7	
	stopsignal :TERM
	user 'rundeck'
	redirect_stderr true
	action :enable
end