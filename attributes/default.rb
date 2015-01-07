include_attribute "kagent"
include_attribute "hadoop"

node.normal[:hadoop][:version]             = "2.2.0"
default[:hops][:download_url]              = "#{node[:download_url]}/hops-#{node[:hadoop][:version]}.tgz"
default[:hops][:hadoop_src_url]            = "#{node[:download_url]}/hadoop-#{node[:hadoop][:version]}-src.tar.gz"

default[:hadoop][:storage_type]            = "clusterj"
default[:hadoop][:leader_check_interval_ms]= 1000
default[:hadoop][:missed_hb]               = 1
default[:hadoop][:repl]                    = 1
default[:hadoop][:db]                      = "hop"
default[:hadoop][:max_retries]             = 0

# set the location of libndbclient.so. set-env.sh sets LD_LIBRARY_PATH to find this library.
default[:ndb][:libndb]                     = "#{default[:mysql][:version_dir]}/lib"
default[:mysql][:port]                     = default[:ndb][:mysql_port]
default[:hadoop][:mysql_url]               = "jdbc:mysql://#{default[:ndb][:mysql_ip]}:#{default[:ndb][:mysql_port]}/"

