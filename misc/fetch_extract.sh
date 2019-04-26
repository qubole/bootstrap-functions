#!/bin/bash

##
# Extracts an archive to a destination directory specified
# param1 - Path to archive file. Mandatory parameter
# param2 - Destination directory. Optional
#
function extract() {
    archive=$1
    destination=$2

    if [[ $# -eq 0 ]]; then
        echo "Usage: extract <archive> [destination]"
    else
        comm="tar xf ${archive}"
        if [[ ! -z ${destination} ]]; then
            comm="${comm} -C ${destination}"
        fi
        ${comm}
        echo "Extracted ${archive}"
    fi
}

##
# Fetches an archive specified by the url using curl and extracts it to a destination directory
# param1 - URL of the archive. Mandatory parameter
# param2 - Destination directory. Optional
#
function fetch_extract() {
    url=$1
    destination=$2

    if [[ $# -eq 0 ]]; then
        echo "Usage: fetch_extract <url> [destination]"
    else
        comm="curl -sL ${url} | tar xf -"
        if [[ ! -z ${destination} ]]; then
            comm="${comm} -C ${destination}"
        fi
        ${comm}
        echo "Fetched and extracted ${url}"
    fi
}
