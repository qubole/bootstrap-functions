#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh
export PROFILE_FILE=${PROFILE_FILE:-/etc/profile}
export HADOOP_ETC_DIR=${HADOOP_ETC_DIR:-/usr/lib/hadoop2/etc/hadoop}

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

function restart_worker_services() {
  monit unmonitor datanode
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/hadoop-daemon.sh stop datanode' hdfs
  /bin/su -s /bin/bash -c '/usr/lib/hadoop2/sbin/hadoop-daemon.sh start datanode' hdfs
  monit monitor datanode
  # No need to restart nodemanager since it starts only
  # after thhe bootstrap is finished
}

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
