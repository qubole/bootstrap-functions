#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh

livy_server_version="0.3.0"
livy_server_dir="livy-server-${livy_server_version}"

function start_livyserver() {
    is_master=$(nodeinfo is_master)
    if [[ $is_master == "1" ]]; then
        export SPARK_HOME=/usr/lib/spark
        export HADOOP_CONF_DIR=/etc/hadoop/conf
        pushd /media/ephemeral0/livy/${livy_server_dir}
        echo "Starting livy-server.."
        nohup ./bin/livy-server > ./logs/livy.out 2> ./logs/livy.err < /dev/null &
        popd
    fi
}

function stop_livyserver() {
    is_master=$(nodeinfo is_master)
    if [[ $is_master == "1" ]]; then
        echo "Stopping livy-server.."
        pkill -f "livy-server-${livy_server_version}.*com.cloudera.livy.server.LivyServer"
    fi
}

function restart_livyserver() {
    stop_livyserver && sleep 2 && start_livyserver
}

function install_livyserver() {
    is_master=$(nodeinfo is_master)
    if [[ $is_master == "1" ]]; then
        echo "Installing livy-server-${livy_server_version}"
        mkdir -p /media/ephemeral0/livy
        pushd /media/ephemeral0/livy
        wget http://archive.cloudera.com/beta/livy/livy-server-${livy_server_version}.zip
        unzip livy-server-${livy_server_version}.zip

        mkdir -p ${livy_server_dir}/logs
        echo livy.spark.master=yarn >> ${livy_server_dir}/conf/livy.conf
        echo livy.spark.deployMode=client >> ${livy_server_dir}/conf/livy.conf
        echo livy.repl.enableHiveContext=true >> ${livy_server_dir}/conf/livy.conf
        popd
    fi
    start_livyserver
}
