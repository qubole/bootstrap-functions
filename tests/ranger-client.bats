load helpers/file_helper

# RANGER_HOST=test-host
# RANGER_PORT=6081
# RANGER_REPO=testdev
RANGER_HOST=localhost
RANGER_PORT=6080
RANGER_REPO=hivedev
RANGER_URL=http://${RANGER_HOST}:${RANGER_PORT}
HIVE_LIB=/usr/lib/hive1.2
RANGER_HIVE_PLUGIN_PATH=/media/ephemeral0/hive_plugin/ranger-1.1.0-hive-plugin

function setup() {
    if [[ ! -e /tmp/RANGER_INSTALLED ]]; then
        source /usr/lib/qubole/bootstrap-functions/hive/ranger-client.sh
        install_ranger -h ${RANGER_HOST} -p ${RANGER_PORT} -r ${RANGER_REPO}
        touch /tmp/RANGER_INSTALLED
    fi
}

@test "Ranger directory exists" {
    assert_dir_exists ${RANGER_HIVE_PLUGIN_PATH}
}

@test "install.properties contains repo name" {
    assert_file_contains "REPOSITORY_NAME=${RANGER_REPO}" ${RANGER_HIVE_PLUGIN_PATH}/install.properties
}

@test "install.properties contains policy mgr url" {
    assert_file_contains "POLICY_MGR_URL=${RANGER_URL}" ${RANGER_HIVE_PLUGIN_PATH}/install.properties
}

@test "install.properties contains component install dir name" {
    assert_file_contains "COMPONENT_INSTALL_DIR_NAME=${HIVE_LIB}" ${RANGER_HIVE_PLUGIN_PATH}/install.properties
}

@test "enable-hive-plugin.sh contains hcomponent install dir" {
    assert_file_contains "HCOMPONENT_INSTALL_DIR=${HIVE_LIB}" ${RANGER_HIVE_PLUGIN_PATH}/enable-hive-plugin.sh
}

@test "verify ranger jars were copied to hive lib" {
    location=${HIVE_LIB}/lib
    ranger_jars=( eclipselink-2.5.2.jar httpclient-4.5.3.jar httpcore-4.4.6.jar httpmime-4.5.3.jar javax.persistence-2.1.0.jar noggit-0.6.jar ranger-hive-plugin-1.1.0.jar ranger-hive-plugin-impl ranger-hive-plugin-shim-1.1.0.jar ranger-plugin-classloader-1.1.0.jar ranger-plugins-audit-1.1.0.jar ranger-plugins-common-1.1.0.jar ranger-plugins-cred-1.1.0.jar solr-solrj-5.5.4.jar )
    assert_multiple_files_exist $location "${ranger_jars[@]}"
}

@test "Ranger configs in hiveserver2-site.xml" {
    assert_file_contains "org.apache.ranger.authorization.hive.authorizer.RangerHiveAuthorizerFactory" /usr/lib/hive1.2/conf/hiveserver2-site.xml
}

@test "JAVA uses version 8" {
    run bash -c 'alternatives --display java | grep "currently points to" | grep -qs "1.8.0"'
    [[ ${status} -eq 0 ]]
}

@test "JAVA_HOME updated in hadoop-env.sh" {
    assert_file_contains "export JAVA_HOME=/usr/lib/jvm/jre" /usr/lib/hadoop2/etc/hadoop/hadoop-env.sh
}
