libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')
require 'resolv'

ndb_connectstring()

directory "#{node[:hadoop][:dir]}/ndb-hops-#{node[:hadoop][:version]}-#{node[:ndb][:version]}" do
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "755"
  action :create
  recursive true
end

link "#{node[:hadoop][:dir]}/ndb-hops" do
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  to "#{node[:hadoop][:dir]}/ndb-hops-#{node[:hadoop][:version]}-#{node[:ndb][:version]}"
end

package_url = node[:dal][:download_url]
base_filename = File.basename(package_url)

remote_file "#{node[:hadoop][:dir]}/ndb-hops/#{base_filename}" do
  source package_url
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "0755"
  # TODO - checksum
  action :create_if_missing
end

clusterj_url = node[:clusterj][:download_url]
clusterj_filename = File.basename(clusterj_url)

remote_file "#{node[:hadoop][:dir]}/ndb-hops/#{clusterj_filename}" do
  source clusterj_url
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "0755"
  # TODO - checksum
  action :create_if_missing
end

# bash 'clusterj-ownership' do
#   user "root"
#   group "root"
#   code <<-EOH
#         chown #{node[:hdfs][:user]}:#{node[:hadoop][:group]} #{node[:mysql][:base_dir]}/share/java/clusterj* 
#         chmod 751 #{node[:mysql][:base_dir]}/share/java/clusterj* 
# 	EOH
# end


hin = "#{node[:hadoop][:home]}/.#{base_filename}_dal_downloaded"
bash 'extract-hadoop' do
  user node[:hdfs][:user]
  group node[:hadoop][:group]
  code <<-EOH
        set -e
        rm -f #{node[:hadoop][:home]}/share/hadoop/common/lib/ndb-dal.jar
	ln -s #{node[:hadoop][:dir]}/ndb-hops/#{base_filename} #{node[:hadoop][:home]}/share/hadoop/common/lib/ndb-dal.jar
        rm -f #{node[:hadoop][:home]}/etc/hadoop/ndb.props

        rm -f #{node[:hadoop][:home]}/share/hadoop/common/lib/clusterj.jar
	ln -s #{node[:hadoop][:dir]}/ndb-hops/#{clusterj_filename} #{node[:hadoop][:home]}/share/hadoop/common/lib/clusterj.jar

	rm -f #{node[:hadoop][:home]}/lib/native/libndbclient.so
	ln -s #{node[:mysql][:base_dir]}/lib/libndbclient.so* #{node[:hadoop][:home]}/lib/native

        touch #{hin}
	EOH
  not_if { ::File.exist?("#{hin}") }
end


template "#{node[:hadoop][:home]}/etc/hadoop/ndb.props" do
  source "ndb.props.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "755"
  variables({
              :ndb_connectstring => node[:ndb][:connect_string],
              :mysql_host => node[:ndb][:connect_string].split(":").first,
            })
end