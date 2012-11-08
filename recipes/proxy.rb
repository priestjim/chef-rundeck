#
# Cookbook Name:: chef-rundeck
# Recipe:: proxy
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

include_recipe 'nginx'

template "#{node['nginx']['dir']}/sites-available/rundeck" do
	source 'nginx_proxy.erb'
	owner 'root'
	group 'root'
	mode 00644
	if(::File.symlink?("#{node['nginx']['dir']}/sites-enabled/rundeck"))
		notifies :reload, 'service[nginx]', :immediately
	end
end

nginx_site 'rundeck'