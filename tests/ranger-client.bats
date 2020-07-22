load helpers/file_helper
source /usr/lib/qubole/bootstrap-functions/hive/ranger-client.sh
source /usr/lib/qubole/bootstrap-functions/common/utils.sh

RANGER_HOST=localhost
RANGER_PORT=6080
RANGER_REPO=hivedev
RANGER_URL=http://${RANGER_HOST}:${RANGER_PORT}
HIVE_LIB=/usr/lib/hive1.2
HIVE_VERSION=$(nodeinfo hive_version)

function set_plugin_version() {
    if [[ "${HIVE_VERSION}" == "1.2" || "${HIVE_VERSION}" == "2.1.1" ]]; then
        PLUGIN_VERSION="1.1.0"
    elif [[ "${HIVE_VERSION}" == "2.3" ]]; then
        PLUGIN_VERSION="1.2.0"
    else
        PLUGIN_VERSION="2.0.0"
    fi
    RANGER_HIVE_PLUGIN_PATH=/media/ephemeral0/hive_plugin/ranger-${PLUGIN_VERSION}-hive-plugin
}

function setup() {
    set_plugin_version
    if [[ ! -e /tmp/RANGER_INSTALLED ]]; then
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
    if [[ ${HIVE_VERSION} != "1.2" && ${HIVE_VERSION} != 2* ]]; then
        ranger_jars=( eclipselink-2.5.2.jar gethostname4j-0.0.2.jar httpclient-4.5.3.jar httpcore-4.4.6.jar httpmime-4.5.3.jar jna-5.2.0.jar jna-platform-5.2.0.jar noggit-0.8.jar ranger-hive-plugin-${PLUGIN_VERSION}.jar ranger-hive-plugin-impl ranger-hive-plugin-shim-${PLUGIN_VERSION}.jar ranger-plugin-classloader-${PLUGIN_VERSION}.jar ranger-plugins-audit-${PLUGIN_VERSION}.jar ranger-plugins-common-${PLUGIN_VERSION}.jar ranger-plugins-cred-${PLUGIN_VERSION}.jar solr-solrj-7.7.1.jar )
    else
        ranger_jars=( eclipselink-2.5.2.jar httpclient-4.5.3.jar httpcore-4.4.6.jar httpmime-4.5.3.jar javax.persistence-2.1.0.jar noggit-0.6.jar ranger-hive-plugin-${PLUGIN_VERSION}.jar ranger-hive-plugin-impl ranger-hive-plugin-shim-${PLUGIN_VERSION}.jar ranger-plugin-classloader-${PLUGIN_VERSION}.jar ranger-plugins-audit-${PLUGIN_VERSION}.jar ranger-plugins-common-${PLUGIN_VERSION}.jar ranger-plugins-cred-${PLUGIN_VERSION}.jar solr-solrj-5.5.4.jar )
    fi
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
