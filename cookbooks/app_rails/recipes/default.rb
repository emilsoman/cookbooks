#
# Cookbook Name:: app_rails 
# Recipe:: default
#
# Copyright 2012, Emil Soman
#
# License - MIT
#

puts "Available nodes in data bag = #{data_bag('nodes').inspect}"
if node['cloud_environment_id'].nil?
  environment_id = data_bag_item('nodes', Chef::Config[:node_name])['environment_id']
  node.set['cloud_environment_id'] = environment_id
end
puts "Cloud Environment ID of node #{Chef::Config[:node_name]} = #{node.cloud_environment_id.inspect}"


=begin
Chef::Log.info("Printing : #{data_bag('nodes').inspect}")
project_id = data_bag_item('nodes', Chef::Config[:node_name])["project_id"]
puts "project id = #{project_id}"
puts "data bags for projects = #{data_bag('projects')}"
project_name = data_bag_item('projects', project_id)['name']
puts "project name = #{project_name}"
=end
project_name = "test_app"

package "apt"

package "libsqlite3-dev"
package "nodejs"
package "libmysqlclient-dev"

application "app_rails" do
  owner 'ubuntu'
  group 'admin'
  path "/deploy/#{project_name}"
  repository "git@github.com:emilsoman/rails_test_app.git"
  revision "HEAD"
  environment_name "development"
  migrate true
  rails do
    gems ["bundler"]
    database_master_role "app_db"
    database do
      database "#{project_name}_production"
      username "root"
      password "root"
      adapter "mysql2"
    end
  end

  unicorn do
    bundler false
  end

  memcached do
    role "memcached"
    options do
      ttl 1800
      memory 256
    end
  end

end