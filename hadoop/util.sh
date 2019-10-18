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

##
# Wait until namenode is out of safe mode.
# Takes 2 optional params
# first : Number of attempts function will make to get namenode out of safemode. Default is 50
# second : Number of seconds each attempt will sleep for waiting for namenode to come out of sleep mode. Default is 5sec
function wait_until_namenode_running() {
    n=0
    attempts=${1:-50}
    sleep_sec=${2:-5}
    
    nn_out_of_safe_mode=0
    until [ $n -ge $attempts ]
    do
        n=$[$n+1]
        safe_mode_stat=`hadoop dfsadmin -safemode get|awk '{print $4}'`
        if [[ $safe_mode_stat = "ON" ]]; then
            hdfs hadoop dfsadmin -safemode leave
            echo "Attempt $n/$attempts"
            sleep $sleep_sec
        else
            echo "NN is out of safemode..."
            nn_out_of_safe_mode=1
            break
        fi
    done
    if [[ $nn_out_of_safe_mode -eq 0 ]]; then
        safe_mode_stat=`hadoop dfsadmin -safemode get|awk '{print $4}'`
        if [[ $safe_mode_stat = "ON" ]]; then
                echo "Node still in safe mode after all attempts exhausted!"
        else
            echo "NN is out of safemode..."
        fi
    fi
    
}
