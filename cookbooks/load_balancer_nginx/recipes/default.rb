if node['cloud_environment_id'].nil?
  environment_id = data_bag_item('nodes', Chef::Config[:node_name])['environment_id']
  node.set['cloud_environment_id'] = environment_id
end
log "Cloud Environment ID of node #{Chef::Config[:node_name]} = #{node.cloud_environment_id.inspect}"

app_instances_deployed = true

search(:node, "role:app AND cloud_environment_id:#{node['cloud_environment_id']}") do |n|
  #If all app instances are deployed , continue
  log "n['app_deployed'] for #{n['name']} = #{n['app_deployed']}"
  app_instances_deployed = false if n['app_deployed'].to_s != "true"
end


if app_instances_deployed
  include_recipe "load_balancer_nginx::deploy"
end
