#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh

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
 echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0_60" >> /etc/profile
 echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile
 
 sed -i 's/java-1.7.0/java-1.8.0_60/' /etc/hadoop/hadoop-env.sh
 sed -i 's/java-1.7.0/java-1.8.0_60/' /etc/hadoop/mapred-env.sh
 sed -i 's/java-1.7.0/java-1.8.0_60/' /etc/hadoop/yarn-env.sh

 is_master=$(nodeinfo is_master)
 if [[ "$is_master" == "1" ]]; then
   restart_master_services
 else
   restart_worker_services
 fi
}
