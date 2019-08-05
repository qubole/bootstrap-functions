#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh
export PROFILE_FILE=${PROFILE_FILE:-/etc/profile}
export HADOOP_ETC_DIR=${HADOOP_ETC_DIR:-/usr/lib/hadoop2/etc/hadoop}

##
# Restart hadoop services on the cluster master
#
# This may be used if you're using a different version
# of Java, for example
#
function restart_master_services() {

  monit unmonitor namenode
  monit unmonitor timelineserver
  monit unmonitor historyserver
  monit unmonitor resourcemanager

  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/yarn-daemon.sh stop timelineserver' yarn
  /bin/su -s /bin/bash -c 'HADOOP_LIBEXEC_DIR=/usr/lib/hadoop2/libexec /usr/lib/hadoop2/sbin/mr-jobhistory-daemon.sh stop historyserver' mapred
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/yarn-daemon.sh stop resourcemanager' yarn
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/hadoop-daemon.sh stop namenode' hdfs

  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/hadoop-daemon.sh start namenode' hdfs
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/yarn-daemon.sh start resourcemanager' yarn
  /bin/su -s /bin/bash -c 'HADOOP_LIBEXEC_DIR=/usr/lib/hadoop2/libexec /usr/lib/hadoop2/sbin/mr-jobhistory-daemon.sh start historyserver' mapred
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/yarn-daemon.sh start timelineserver' yarn

  monit monitor namenode
  monit monitor resourcemanager
  monit monitor historyserver
  monit monitor timelineserver
}


##
# Restart hadoop services on cluster workers
#
# This only restarts the datanode service since the
# nodemanager is started after the bootstrap is run
#
function restart_worker_services() {
  monit unmonitor datanode
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/hadoop-daemon.sh stop datanode' hdfs
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/hadoop-daemon.sh start datanode' hdfs
  monit monitor datanode
  # No need to restart nodemanager since it starts only
  # after thhe bootstrap is finished
}

##
# Use Java 8 for hadoop daemons and jobs
#
# By default, the hadoop daemons and jobs on Qubole
# clusters run on Java 7. Use this function if you would like
# to use Java 8. This is only required if your cluster:
# is in AWS, and
# is running Hive or Spark < 2.2
#
function use_java8() {
 export JAVA_HOME=/usr/lib/jvm/java-1.8.0
 export PATH=$JAVA_HOME/bin:$PATH
 echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0" >> "$PROFILE_FILE"
 echo "export PATH=$JAVA_HOME/bin:$PATH" >> "$PROFILE_FILE"
 
 sed -i 's/java-1.7.0/java-1.8.0/' "$HADOOP_ETC_DIR/hadoop-env.sh"

 is_master=$(nodeinfo is_master)
 if [[ "$is_master" == "1" ]]; then
   restart_master_services
 else
   restart_worker_services
 fi
}

# Mount given lustre fsx DNS as Shuffle Directory
# Mandatory functional param -> Lustre Dns Name
function mount_lustre_as_shuffle_dir() {
  lustre_dns=$1
  if [ -z "$lustre_dns" ]; then
   echo "Specifying Lustre DNS is must!"
   return 1
  else
   mkdir -p /lustre/qubole
   mount -t lustre ${lustre_dns}@tcp:/fsx /lustre/qubole
   chmod 777 /lustre
   chmod 777 /lustre/qubole
  fi
}
