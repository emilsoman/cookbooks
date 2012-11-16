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

execute "apt update" do
  command "sudo apt-get update"
end

package "libsqlite3-dev"
package "nodejs"
package "libmysqlclient-dev"

secret_key = <<EOF
-----BEGIN RSA PRIVATE KEY-----
  MIIEowIBAAKCAQEAuUi/l+yeOeZ8K+89xLk3BR/2q1UmaEnPUn00no1vPF75LFwg
1klPmoNw8q0sfA2PUe20h9GjjgQjBVQf+psmrW8HC/gtj4koxDUo3s+1hkLEEgiL
M48wm5efLazk1gwdt4QR1sp2zdfxAyIY8WilbF6k6iU2EvI9mXXIzZKnMshH4D6d
ut1rFW1dPwWj6RfV3eyt9jYB4AsuQgjPcQwI32DRgn2eJBW+bsnyONzWneOlpLAl
0hJIgpUB8NFUx4Vv7FesX4Cse8A1q8fk41SUh9CiJkZ5CglHxodRaPGYRQnxeO5V
g8yxFhWRlQzQqnajQxi1+ZFn2y2hzSGSGdoUsQIDAQABAoIBADIt7p2hmpSJxHVN
nMfrdWgw6Ogr7nPuEXUArcCHA2oxOoB2DvqZ7jIliPBgUBzkuzzwCKWD9CyhGC74
QpTncgkkeZ8XPpeSCPVihEgbrsjGyj0sDS8Qh5SL8rM3EN6bd2zdGsu2F4jWA9La
aDDxK2P3GejD3SoyatZl3NU384o/1zo+OBybY5fGxLZTsLrA/GdQAhXTUavco8HF
1/p2yz1ROB2OrIfz30GVv8aLxRTLo6E67Fk8qgLGKHdNhCATfFs/gEQfn3rOf9py
A0y5A6vPmlHNkZ6sKIBG/TZulFTIWVR1nT1gO14nZYXstpnw/KBDnzet/1agiQAN
/WHRLfUCgYEA7SSK7WgXIdEFxXvbbHoJ+ZdbwbVOnw0hS8zJxtLKRLJtvTIo6PAj
MyREza4NVbgnMruys6gxH4u6wcidY3/5d9OUtkrefyluJ3c6DqtEz0+01ypYZUH6
/Cn625+DMbJ1Ow0LWbP89uv/BMSgShIQxOHJ9tt5mKipqhg3QZ/acLcCgYEAyASI
ix0VaOjebyUURx64XvnI4TUoTGDoMCpAJdmRqVi3v/gimY8KG904Sjnm8mL2stnH
o3XVK68YDRstyr8FXTyxMt2yUo5zpwHM2yfUr8nhotaL2SH1s3e/ZXQbEOSGSaD+
  hauWbUv8gZLgR6vVBW9Wg4fFD/aswyAF8XVU7dcCgYBbpfPLLJ9EAnQojmWO1ttk
Cor7ogZwkbJ8iPiyTmS9h/fBVtFYtPXlne65Trr4leMQSFoX9LiHaIkUu2OYQK05
Ehw3F1hF7M0Vk45sfORq+nL5dPQUrhtBuTeqCUu6uS11VOU+FcF97FbykMsh1TmF
3X0gWlH0Hbr0ccdpJU5WoQKBgQC+1MxtZYcqu5qVEhxhqmafftNwQqY7EO4WHglr
00OM/a76gcSJG5a6dPqintHACjly9CLryp1ie0CIKJks6ck1ZpVtgWUELRMckLQh
l8PtH8Cd+vIcbLEd1C8QnZDBMjcJAogzgj0X9DpqaXaACupHsC0reprCG0hDNkdV
Uut/qwKBgF65EEu4Fksg1TvrmcU9piiZLSCU8LWmEbwH+rcKi5jTaXqZ+tbwHwqi
kAmjphv/mGqixw4wmuHtdEYIWQRHXZgiYfER6Vgw1a8j8ClxUNaHwS2b2pJdFRt8
D15zIoJ9QyMXRqClYNI+HjRd5Xerv5RQosHGQ3iKbqI8/GyT3E3j
-----END RSA PRIVATE KEY-----
EOF

application "app_rails" do
  owner 'ubuntu'
  group 'admin'
  path "/deploy/#{project_name}"
  repository "git@github.com:emilsoman/rails_test_app.git"
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
