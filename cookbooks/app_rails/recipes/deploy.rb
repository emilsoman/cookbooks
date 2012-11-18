puts "Available nodes in data bag = #{data_bag('nodes').inspect}"
if node['cloud_environment_id'].nil?
  environment_id = data_bag_item('nodes', Chef::Config[:node_name])['environment_id']
  node.set['cloud_environment_id'] = environment_id
end
puts "Cloud Environment ID of node #{Chef::Config[:node_name]} = #{node.cloud_environment_id.inspect}"


node_details = data_bag_item('nodes', Chef::Config[:node_name])
project = data_bag_item('projects', node_details['project_id'])
project_name = project["name"]
secret_key = project["deploy_key"]
repo = project["repo"]

package "apt"

execute "apt update" do
  command "sudo apt-get update"
end

package "libsqlite3-dev"
package "nodejs"
package "libmysqlclient-dev"

application "app_rails" do
  owner 'ubuntu'
  group 'admin'
  path "/deploy/#{project_name}"
  repository repo
  revision "HEAD"
  environment_name "development"
  deploy_key secret_key
  rails do
    gems ["bundler"]
    database_master_role "db"
    database do
      database project_name
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

ruby_block do
  block do
    node_details = data_bag_item('nodes', Chef::Config[:node_name])
    project = data_bag_item('projects', node_details['project_id'])
    app_instances_deployed = project["environments"][node_details["environment_id"]]["app_instances_deployed"]
    app_instances_deployed = app_instances_deployed.split(",")
    puts "app instances deployed before = #{app_instances_deployed}"
    unless app_instances_deployed.include?(Chef::Config[:node_name])
      app_instances_deployed << Chef::Config[:node_name]
      project["environments"][node_details["environment_id"]]["app_instances_deployed"] = app_instances_deployed.join(",")
      project.save
    end
    puts "app instances deployed after ======== #{project["environments"][node_details["environment_id"]]["app_instances_deployed"]}"
  end
end
