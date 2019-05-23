#!/bin/bash

##
# Configure AWS CLI
# -p: Name of the profile. Defaults to `default`
# -a: AWS access key
# -s: AWS secret key
# -r: AWS region
#
function configure_awscli() {
    PROFILE=default

    while getopts ":p:a:s:r:" opt; do
        case ${opt} in
            p)
                PROFILE=${OPTARG}
                ;;
            a)
                ACCESS_KEY=${OPTARG}
                ;;
            s)
                SECRET_KEY=${OPTARG}
                ;;
            r)
                REGION=${OPTARG}
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
    if [[ ! -z ${ACCESS_KEY} ]]; then
        aws configure set aws_access_key_id ${ACCESS_KEY} --profile ${PROFILE}
    fi
    if [[ ! -z ${SECRET_KEY} ]]; then
        aws configure set aws_secret_access_key ${SECRET_KEY} --profile ${PROFILE}
    fi
    if [[ ! -z ${REGION} ]]; then
        aws configure set region ${REGION} --profile ${PROFILE}
    fi
}