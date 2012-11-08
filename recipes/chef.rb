#
# Cookbook Name:: chef-rundeck
# Recipe:: chef
#
# Requires the rvm cookbook from github.com/priestjim
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

include_recipe 'rvm'

rvm_user_altinstall 'rundeck' do
	user 'rundeck'
	group 'rundeck'
	home '/var/lib/rundeck'
	version '1.9.3'
end

node['rundeck']['chef']['gems'].each do |gem|
	rvm_gem gem do
		action :upgrade
		user 'rundeck'
	end
end

# Update the default rundeck profile to include the RVM path
cookbook_file "/etc/rundeck/profile" do
	source "profile"
	owner 'rundeck'
	group 'rundeck'
	mode 00640
end
