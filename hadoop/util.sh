#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh
export PROFILE_FILE=${PROFILE_FILE:-/etc/profile}
export HADOOP_ETC_DIR=${HADOOP_ETC_DIR:-/etc/hadoop}

function restart_master_services() {
  monit restart resourcemanager
  monit restart namenode
}

function restart_worker_services() {
  monit restart datanode
}

function use_java8() {
 export JAVA_HOME=/usr/lib/jvm/java-1.8.0_60
 export PATH=$JAVA_HOME/bin:$PATH
 echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0_60" >> "$PROFILE_FILE"
 echo "export PATH=$JAVA_HOME/bin:$PATH" >> "$PROFILE_FILE"
 
 sed -i 's/java-1.7.0/java-1.8.0_60/' "$HADOOP_ETC_DIR/hadoop-env.sh"
 sed -i 's/java-1.7.0/java-1.8.0_60/' "$HADOOP_ETC_DIR/mapred-env.sh"
 sed -i 's/java-1.7.0/java-1.8.0_60/' "$HADOOP_ETC_DIR/yarn-env.sh"

 is_master=$(nodeinfo is_master)
 if [[ "$is_master" == "1" ]]; then
   restart_master_services
 else
   restart_worker_services
 fi
}
