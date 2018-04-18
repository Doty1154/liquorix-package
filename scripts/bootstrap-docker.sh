#!/bin/bash

set -euo pipefail

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh"

cd "$dir_base/scripts"

if ! which docker; then
    echo "[ERROR] Docker is not installed, cannot continue!"
    exit 1
fi

declare -i processes_default=2
declare -i processes=${1:-"$processes_default"}

if [[ $processes -eq $processes_default ]]; then
    echo "[INFO ] Using default process count, $processes"
else
    echo "[INFO ] Using override process count, $processes"
fi

# Build arguments to bootstrap images in parallel
declare -a distros=('debian' 'ubuntu')
declare -a args=()
for distro in "${distros[@]}"; do

    declare -a releases=()
    if [[ "$distro" == 'debian' ]]; then
        releases=("${releases_debian[@]}")
    elif [[ "$distro" == 'ubuntu' ]]; then
        releases=("${releases_ubuntu[@]}")
    fi

    for release  in "${releases[@]}"; do
        args+=("$distro" "$release")
    done
done

# Then pass them into _bootstrap_image with xargs
for item in "${args[@]}"; do
    echo "$item"
done | xargs -n2 -P "$processes" "$dir_base/scripts/bootstrap-docker-image.sh"