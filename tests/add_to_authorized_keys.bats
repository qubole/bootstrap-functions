load helpers/file_helper

EC2_USER_AUTHORIZED_KEYS=/home/ec2-user/.ssh/authorized_keys
EC2_KEY="testabc ec2-user@example.com"

ROOT_AUTHORIZED_KEYS=/root/.ssh/authorized_keys
ROOT_KEY="testxyz root@example.com"

function setup() {
    if [[ ! -e /tmp/SSH_KEYS_UPDATED ]]; then
        source /usr/lib/qubole/bootstrap-functions/misc/util.sh
        add_to_authorized_keys "${EC2_KEY}"
        add_to_authorized_keys "${ROOT_KEY}" root
        touch /tmp/SSH_KEYS_UPDATED
    fi
}

@test "ec2-user authorized_keys contains key" {
    assert_file_contains "${EC2_KEY}" ${EC2_USER_AUTHORIZED_KEYS}
}

@test "ec2-user authorized_keys has correct mode" {
    assert_file_mode ${EC2_USER_AUTHORIZED_KEYS} 600
}

@test "root authorized_keys contains key" {
    assert_file_contains "${ROOT_KEY}" ${ROOT_AUTHORIZED_KEYS}
}

@test "root authorized_keys has correct mode" {
    assert_file_mode ${ROOT_AUTHORIZED_KEYS} 600
}
