#
# Cookbook Name:: rails_app 
# Recipe:: default
#
# Copyright 2012, Emil Soman
#
# License - MIT
#

puts "_________________"
puts data_bag('nodes').inspect
puts "_________________"

=begin
Chef::Log.info("Printing : #{data_bag('nodes').inspect}")
project_id = data_bag_item('nodes', Chef::Config[:node_name])["project_id"]
puts "project id = #{project_id}"
puts "data bags for projects = #{data_bag('projects')}"
project_name = data_bag_item('projects', project_id)['name']
puts "project name = #{project_name}"
=end

application "rails_app" do
  owner "deploy"
  path "/deploy/#{project_name}"
  repository "git@github.com:emilsoman/rails_test_app.git"
  revision "HEAD"
  environment_name "production"
  rails do
    database_master_role "db"
    precompile_assets true
    database do
      database "#{project_name}_production"
      username "root"
      password "root"
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
