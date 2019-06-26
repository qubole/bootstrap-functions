load helpers/file_helper

ZONEINFO=/usr/share/zoneinfo
LOCALTIME=/etc/localtime
LA_TZ=America/Los_Angeles
LA_TZ_ABBREV=PDT

function setup() {
    if [[ ! -e /tmp/TZ_CHANGED ]]; then
        source /usr/lib/qubole/bootstrap-functions/misc/util.sh
        set_timezone ${LA_TZ}
        touch /tmp/TZ_CHANGED
    fi
}

@test "localtime backed up" {
    assert_file_exists "${LOCALTIME}.old"
}

@test "localtime is a symlink" {
    assert_file_is_symlink ${LOCALTIME}
}

@test "localtime is symlinked to ${LA_TZ}" {
    assert_symlinked_to ${LOCALTIME} "${ZONEINFO}/${LA_TZ}"
}

@test "date displays correct timezone" {
    run date +%Z
    [[ ${output} == ${LA_TZ_ABBREV} ]]
}
