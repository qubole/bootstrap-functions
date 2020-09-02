#!/bin/bash
#
# @file misc/datadog.sh
# @brief Provides functions to configure Datadog agent

# @description Configure Datadog agent
#
# This function sets up the api_key and endpoint
# for the Datadog agent
#
# @example
#   configure_dd_agent -k abc12345xyz -e https://app.myddurl.com
#
# @arg -k string Datadog api_key
# @arg -e string Datadog endpoint
#
# @exitcode 0 Datadog agent is configured
# @exitcode 1 Datadog agent config file not found
function configure_dd_agent() {
    local DD_CONFIG=/etc/datadog-agent/datadog.yaml

    while getopts ":k:e:" opt; do
        case ${opt} in
            k)
                DD_API_KEY=${OPTARG}
                ;;
            e)
                DD_ENDPOINT=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -${OPTARG}" >&2
                return 1
                ;;
            :)
                echo "Option -${OPTARG} requires an argument." >&2
                return 1
                ;;
        esac
    done

    if [[ -f ${DD_CONFIG} ]]; then
        if [[ ! -z ${DD_API_KEY} ]]; then
            sed -i "s|^api_key:.*|api_key: ${DD_API_KEY}|" ${DD_CONFIG}
        fi
        if [[ ! -z ${DD_ENDPOINT} ]]; then
            sed -i "s|^#*\s*dd_url:.*|dd_url: ${DD_ENDPOINT}|" ${DD_CONFIG}
        fi
    else
        echo "Datadog agent config file not found.."
        return 1
    fi
}
