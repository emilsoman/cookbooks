if node['cloud_environment_id'].nil?
  environment_id = data_bag_item('nodes', Chef::Config[:node_name])['environment_id']
  node.set['cloud_environment_id'] = environment_id
end
log "Cloud Environment ID of node #{Chef::Config[:node_name]} = #{node.cloud_environment_id.inspect}"

db_resolved = false

node_details = data_bag_item('nodes', Chef::Config[:node_name])
project = data_bag_item('projects', node_details['project_id'])
db_instance_present = project["environments"][node_details["environment_id"]]["db_instance_present"]

log "Db instance present = #{db_instance_present}"

if db_instance_present.to_s == "true"
  rds_ip_address = project["environments"][node_details["environment_id"]]["rds_ip_address"]
  log "Rds ip address = #{rds_ip_address}"
  if rds_ip_address.nil?
    log "Rds not available, searching for 'db' role"
    search(:node, "role:db AND cloud_environment_id:#{node['cloud_environment_id']}") do |n|
      #If db instance was deployed by db_mysql recipe, continue
      db_resolved = true if n['db_deployed'].to_s == "true"
      log "DB instance at #{n['name']} deployed = #{db_resolved}"
    end
  else
    log "RDS ip = #{rds_ip_address}"
    node.set["rds_ip_address"] = rds_ip_address
    #If rds ip address is found , continue
    db_resolved = true
  end
else
  #If the stack is not using a DB, continue
  db_resolved = true
end

if db_resolved
  include_recipe "app_rails::deploy"
end
