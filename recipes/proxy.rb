#
# Cookbook Name:: rundeck
# Recipe:: proxy
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

include_recipe 'rundeck'

srv = node['rundeck']['proxy']['srv']

unless %w( nginx openresty ).include?(srv)
  raise 'Node runlist must include one of nginx or openresty in order to support the rundeck::proxy recipe'
else
  include_recipe srv
end

template "#{node[srv]['dir']}/sites-available/rundeck" do
	source 'nginx_proxy.erb'
	owner 'root'
	group 'root'
	mode 00644
  variables({ :srv => srv })
	if(::File.symlink?("#{node[srv]['dir']}/sites-enabled/rundeck"))
		notifies :reload, 'service[nginx]', :immediately
	end
end

if srv == 'nginx'
  nginx_site 'rundeck'
else
  openresty_site 'rundeck'
end
