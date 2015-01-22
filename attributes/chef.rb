#
# Cookbook Name:: rundeck
# Attribute:: chef
#
# Copyright (C) 2013 Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['rundeck']['chef']['port']            = 9998
default['rundeck']['chef']['client_key']      = ''
default['rundeck']['chef']['client_name']     = ''
default['rundeck']['chef']['partial_search']  = true
default['rundeck']['chef']['cache_timeout']   = 30
default['rundeck']['chef']['ssl_verify_mode'] = :verify_peer
default['rundeck']['chef']['server_url']      = Chef::Config['chef_server_url']