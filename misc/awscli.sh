#!/bin/bash
#
# @file misc/awscli.sh
# @brief Provides function to configure AWS CLI

# @description Configure AWS CLI
# A credentials file containing the AWS Access Key and the AWS Secret Key
# separated by a space, comma, tab or newline must be provided
#
# @example
#   configure_awscli -p exampleprofile -r us-east-1 -c /path/to/credentials/file
#
# @arg -p string Name of the profile. Defaults to `default`
# @arg -r string AWS region. Defaults to `us-east-1`
# @arg -c string Path to credentials file
#
# @exitcode 0 AWS CLI is configured
# @exitcode 1 AWS CLI or credentials file not found
function configure_awscli() {
    PROFILE=default
    REGION=us-east-1

    while getopts ":p:r:c:" opt; do
        case ${opt} in
            p)
                PROFILE=${OPTARG}
                ;;
            r)
                REGION=${OPTARG}
                ;;
            c)
                CREDENTIALS_FILE=${OPTARG}
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

    if [[ ! -x "$(command -v aws)" ]]; then
        echo "AWS CLI was not found.."
        return 1
    fi

    aws configure set region ${REGION} --profile ${PROFILE}

    if [[ ! -z ${CREDENTIALS_FILE} ]]; then
        if [[ -f ${CREDENTIALS_FILE} && -r ${CREDENTIALS_FILE} ]]; then
            OLDIFS="$IFS"
            IFS=$' |\t|\n|,' CONTENTS=( $(cat ${CREDENTIALS_FILE}) )
            IFS="$OLDIFS"
            [[ ${#CONTENTS[@]} -lt 2 ]] && return 1
            ACCESS_KEY=${CONTENTS[0]}
            SECRET_KEY=${CONTENTS[1]}
            aws configure set aws_access_key_id ${ACCESS_KEY} --profile ${PROFILE}
            aws configure set aws_secret_access_key ${SECRET_KEY} --profile ${PROFILE}
        else
            return 1
        fi
    fi
}
