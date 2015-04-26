#
# Cookbook Name:: rundeck
# Attribute:: java
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

# Staring from version 2.5.0-1-GA rundeck requires jdk version 7
default['java']['jdk_version'] = '7'

default['rundeck']['java']['enable_jmx'] = false
default['rundeck']['java']['allocated_memory'] = "#{(node['memory']['total'].to_i * 0.5 ).floor / 1024}m"
default['rundeck']['java']['thread_stack_size'] = '256k'
default['rundeck']['java']['perm_gen_size'] = '512m'
