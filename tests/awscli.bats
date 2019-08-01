load helpers/file_helper

ACCESS_KEY=access_key
SECRET_KEY=secret_key
SEPARATOR=","
AWS_CREDENTIALS_FILE=/tmp/awscreds
AWS_REGION=us-east-1
AWSCLI_CREDENTIALS=/root/.aws/credentials
AWSCLI_CONFIG=/root/.aws/config

function setup() {
    if [[ ! -e /tmp/AWSCLI_CONFIGURED ]]; then
        rm -f ${AWSCLI_CREDENTIALS} ${AWSCLI_CONFIG}
        echo -e "${ACCESS_KEY}${SEPARATOR}${SECRET_KEY}" > ${AWS_CREDENTIALS_FILE}
        source /usr/lib/qubole/bootstrap-functions/misc/awscli.sh
        configure_awscli -r ${AWS_REGION} -c ${AWS_CREDENTIALS_FILE}
        touch /tmp/AWSCLI_CONFIGURED
    fi
}

@test "awscli credentials file contains access key" {
    assert_file_contains ${ACCESS_KEY} ${AWSCLI_CREDENTIALS}
}

@test "awscli credentials file contains secret key" {
    assert_file_contains ${SECRET_KEY} ${AWSCLI_CREDENTIALS}
}

@test "awscli config file contains region" {
    assert_file_contains ${AWS_REGION} ${AWSCLI_CONFIG}
}

@test "awscli credentials file has correct mode" {
    assert_file_mode ${AWSCLI_CREDENTIALS} 600
}

@test "awscli config file has correct mode" {
    assert_file_mode ${AWSCLI_CONFIG} 600
}
