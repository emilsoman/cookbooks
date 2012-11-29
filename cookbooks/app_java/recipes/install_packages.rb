node.set['java']['oracle']['accept_oracle_download_terms'] = true

include_recipe 'java::oracle'

%w{build-essential apache2 }.each do |pkg|
  package pkg do
    action :install
  end
end

file "/var/www/index.html" do
  content "<h1>That was easy!<h1><h2> VisualCloud just provisioned your Java stack for you !</h2>"
end

service "apache" do
  action :start
end
