source /usr/lib/hustler/bin/qubole-bash-lib.sh
is_master=$(nodeinfo is_master)
if [[ ${is_master} = "1" ]]; then
  
    # wait for 4 min to give the HS2 a chance to fully start to avoid racing condition
    # might be a good idea to check for the status
    echo Waiting for 4 min ...
    sleep 240
    echo Done waiting. Printing status of HS2
    sudo monit status hs2
 
    #Ranger Admin HOST and PORT
    RANGER_ADMIN_HOST=internal-ps-aet-alb-new-1081468215.us-east-1.elb.amazonaws.com
    RANGER_ADMIN_PORT=80
    #SOLR HOST and PORT
    RANGER_SOLR_HOST=10.0.5.41
    RANGER_SOLR_PORT=6083
    RANGER_PLUGIN=ranger-2.0.0-hive-plugin
    S3_PATH=s3://pritish-qubole/ranger-2.0.0
    RANGER_PLUGIN_FILE=${S3_PATH}/${RANGER_PLUGIN}.tar.gz
  	SPOOL_DIR=/media/ephemeral0/logs/ranger/hive/audit/solr
  	
    #REPOSITORY_NAME defined in Ranger Admin
    SERVICENAME=hive_qds_policies
  
    # Qubole does periodic health check to make sure that HS2 is healthy. Please give basic read permission to this user in Ranger.
    QBOL_HEALTH_CHECK_USER=qbol_user
      
    export URL=http://${RANGER_ADMIN_HOST}:${RANGER_ADMIN_PORT}
  
    export SERVICE=$SERVICENAME
  
    # We will be using java 8
    source /usr/lib/hustler/bin/qubole-bash-lib.sh
    change_java_version "1.8" "1.8"
  
    #Files that are required to be updated
    export HIVE_LIB=/usr/lib/hive1.2/
    export FILE1=install.properties
    export FILE2=enable-hive-plugin.sh
    export FILE3=/usr/lib/hive1.2/bin/test-hs2.sh
    mkdir /media/ephemeral0/hive_plugin
    cd /media/ephemeral0/hive_plugin
  
    #EXTRACTING and INSTALLING HIVE PLUGIN for RANGER
    ## ranger-hive plugin path
    /usr/lib/hadoop2/bin/hadoop dfs -get $RANGER_PLUGIN_FILE
    tar -xzf $RANGER_PLUGIN.tar.gz
    cd $RANGER_PLUGIN
    /usr/lib/hadoop2/bin/hadoop dfs -get ${S3_PATH}/hc_user.sh
  
    #Script to update the values in install.properties and enable-hive-plugin.sh
    sudo chmod 777 *.sh *.py install.properties
  
    #Configuring the values in install.properties and enable-hive-plugin.sh
    sed -i.bak 's#\(REPOSITORY_NAME=\).*#REPOSITORY_NAME='$SERVICE'#g' $FILE1
    sed -i.bak 's#\(POLICY_MGR_URL=\).*#POLICY_MGR_URL='$URL'#g' $FILE1
    sed -i.bak 's/SQL_CONNECTOR_JAR=\/usr\/share\/java\/mysql-connector-java.jar/SQL_CONNECTOR_JAR=\/usr\/lib\/hive1.2\/lib\/mysql-connector-java-5.1.45.jar/g' $FILE1
    sed -i.bak 's#\(COMPONENT_INSTALL_DIR_NAME=\).*#COMPONENT_INSTALL_DIR_NAME='$HIVE_LIB'#g' $FILE1
    sed -i.bak 's#\(HCOMPONENT_INSTALL_DIR=\).*#HCOMPONENT_INSTALL_DIR='$HIVE_LIB'#g' $FILE2
 
    # Enable Solr
    export SOLR_URL=http://${RANGER_SOLR_HOST}:${RANGER_SOLR_PORT}/solr/ranger_audits
    sed -i.bak 's#\(XAAUDIT.SOLR.ENABLE=\).*#XAAUDIT.SOLR.ENABLE='true'#g' $FILE1
    sed -i.bak 's#\(XAAUDIT.SOLR.URL=\).*#XAAUDIT.SOLR.URL='$SOLR_URL'#g' $FILE1
    sed -i.bak 's#\(XAAUDIT.SOLR.IS_ENABLED=\).*#XAAUDIT.SOLR.IS_ENABLED='true'#g' $FILE1
    sed -i.bak 's#\(XAAUDIT.SOLR.SOLR_URL=\).*#XAAUDIT.SOLR.SOLR_URL='$SOLR_URL'#g' $FILE1
 	
 	sed -i.bak 's#\(XAAUDIT.SOLR.FILE_SPOOL_DIR=\).*#XAAUDIT.SOLR.FILE_SPOOL_DIR='${SPOOL_DIR}'#g' $FILE1
 	
    # Enabling hive plugin for Ranger
    sudo -E bash enable-hive-plugin.sh
  
    # Update Qubole Health check user.
    sudo ./hc_user.sh $FILE3 $QBOL_HEALTH_CHECK_USER
  
    # Copying the RANGER files in the expected path
    cp -r /usr/lib/hive1.2/lib/ranger-hive-plugin-impl/* /usr/lib/hive1.2/lib/
 	
 	sudo chmod -R 757 /etc/ranger/$SERVICE/policycache/
 	
    # Re-start HiveServer2
    sudo monit stop hs2
    sleep 30
    sudo monit start hs2
 
fi