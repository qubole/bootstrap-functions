#!/bin/bash

##
# Configure AWS CLI
# -p: Name of the profile. Defaults to `default`
# -r: AWS region
# -c: Credentials file
# The credentials file must contain the AWS Access Key and
# the AWS Secret Key separated by a space, comma, tab or newline
#
function configure_awscli() {
    PROFILE=default

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
    if [[ ! -z ${REGION} ]]; then
        aws configure set region ${REGION} --profile ${PROFILE}
    fi
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
