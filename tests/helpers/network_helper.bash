#!/bin/bash

function assert_tcp_port_listening() {
    local port=$1
    if ! netstat -tlnp | grep -qs ${port}; then
        return 1
    fi
}

function assert_udp_port_listening() {
    local port=$1
    if ! netstat -ulnp | grep -qs ${port}; then
        return 1
    fi
}
