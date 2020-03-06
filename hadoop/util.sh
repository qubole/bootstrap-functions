#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh
source /usr/lib/qubole/bootstrap-functions/common/utils.sh
export PROFILE_FILE=${PROFILE_FILE:-/etc/profile}
export HADOOP_ETC_DIR=${HADOOP_ETC_DIR:-/usr/lib/hadoop2/etc/hadoop}
declare -A SVC_USERS=([namenode]=hdfs [timelineserver]=yarn [historyserver]=mapred [resourcemanager]=yarn [datanode]=hdfs)

function _start_daemon() {
  local daemon=$1;
  case "${SVC_USERS[$daemon]}" in
    yarn)
      /bin/su -s /bin/bash -c "/usr/lib/hadoop2/sbin/yarn-daemon.sh start $daemon" yarn
      ;;
    hdfs)
      /bin/su -s /bin/bash -c "/usr/lib/hadoop2/sbin/hadoop-daemon.sh start $daemon" hdfs
      ;;
    mapred)
      /bin/su -s /bin/bash -c "HADOOP_LIBEXEC_DIR=/usr/lib/hadoop2/libexec /usr/lib/hadoop2/sbin/mr-jobhistory-daemon.sh start $daemon" mapred
      ;;
    *)
      echo "Invalid daemon $daemon"
      ;;
  esac
}

function _stop_daemon() {
  local daemon=$1;
  case "${SVC_USERS[$daemon]}" in
    yarn)
      /bin/su -s /bin/bash -c "/usr/lib/hadoop2/sbin/yarn-daemon.sh stop $daemon" yarn
      ;;
    hdfs)
      /bin/su -s /bin/bash -c "/usr/lib/hadoop2/sbin/hadoop-daemon.sh stop $daemon" hdfs
      ;;
    mapred)
      /bin/su -s /bin/bash -c "HADOOP_LIBEXEC_DIR=/usr/lib/hadoop2/libexec /usr/lib/hadoop2/sbin/mr-jobhistory-daemon.sh stop $daemon" mapred
      ;;
    *)
      echo "Invalid daemon $daemon"
      ;;
  esac
}

function _restart_services() {
  local svcs=("$@")
  local running_svcs=($(get_running_services "${svcs[@]}"))
  for s in "${running_svcs[@]}"; do
    monit unmonitor "$s"
  done

  for s in "${running_svcs[@]}"; do
    _stop_daemon "$s"
  done

  local last=${#running_svcs[@]}

  # Restart services in reverse order of how
  # they were stopped
  for (( i=last-1; i>=0; i-- )); do
    _start_daemon "${running_svcs[i]}"
  done

  # Order doesn't matter for (un)monitor
  for s in "${running_svcs[@]}"; do
    monit monitor "$s"
  done
}

#
# Restart hadoop services on the cluster master
#
function _restart_master_services() {
  _restart_services timelineserver historyserver resourcemanager namenode
}

#
# Restart hadoop services on cluster workers
#
# This only restarts the datanode service since the
# nodemanager is started after the bootstrap is run
#
function _restart_worker_services() {
  _restart_services datanode
  # No need to restart nodemanager since it starts only
  # after thhe bootstrap is finished
}

##
# Restart hadoop services
#
# This may be used if you're using a different version
# of Java, for example
#
function restart_hadoop_services() {
  local is_master=$(nodeinfo is_master)
  if [[ "$is_master" == "1" ]]; then
    _restart_master_services
  else
    _restart_worker_services
  fi
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
 restart_hadoop_services
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
