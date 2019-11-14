load helpers/file_helper

JAR_FILE_PATH=/usr/lib/hive1.2/lib/HiveGlueCatalogSyncAgent-1.1-SNAPSHOT.jar
HIVE_SITE_PATH=/usr/lib/hive1.2/conf/hive-site.xml
HIVE_SITE_BAK_PATH=/usr/lib/hive1.2/conf/hive-site.xml.bak
REGION=test-region

# Setup and execute
function setup() {
    if [[ ! -e /tmp/GLUE_SYNC_INSTALLED ]]; then
        source /usr/lib/qubole/bootstrap-functions/hive/glue-sync.sh
        install_glue_sync ${REGION} > /dev/null 2>&1
        touch /tmp/GLUE_SYNC_INSTALLED
    fi
}

# Tests
@test "JAR exists" {
    assert_file_exists ${JAR_FILE_PATH}
}

@test "hive-site backup exists" {
    assert_file_exists ${HIVE_SITE_BAK_PATH}
}

@test "hive-site contains test region" {
    assert_file_contains "jdbc:awsathena://athena.${REGION}.amazonaws.com:443" ${HIVE_SITE_PATH}
}

@test "hive-site contains GlueSync event listener" {
    assert_file_contains "com.amazonaws.services.glue.catalog.HiveGlueCatalogSyncAgent" ${HIVE_SITE_PATH}
}
