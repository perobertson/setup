#!/usr/bin/env bash
# Will be empty when piped into bash
# Otherwise it will be the path that was invoked
CMD="${BASH_SOURCE[0]}"

if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    # e: Exit on non 0 exit codes
    # u: Check for undeclared variables
    # o pipefail: Fail if any exit code in a pipeline is a fail
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
# null the glob when nothing matches
shopt -s nullglob

# enable recursive globbing
shopt -s globstar

# Set the PATH here since this may be the first time the script is run
PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:${HOME}/bin:$PATH"

# Set the code path if its not set to where all code will be cloned into
: "${CODE_PATH:=${HOME}/workspace}"

install_git(){
    # Check if git needs installed
    if [[ ! -x "$(command -v git)" ]]; then
        if [[ -x "$(command -v dnf)" ]]; then
            sudo dnf install -y git-core
        elif [[ -x "$(command -v apt-get)" ]]; then
            sudo apt-get update
            # There was a bug in apt that allowed insecure transport
            sudo apt-get install -y apt-transport-https
            sudo apt-get install -y git
        elif [[ -x "$(command -v pacman)" ]]; then
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm git
        else
            echo "WARNING: could not locate git" >&2
        fi
    fi
}

fetch_setup(){
    if [[ ! -d "${CODE_PATH}/gitlab.com/perobertson" ]]; then
        mkdir -pv "${CODE_PATH}/gitlab.com/perobertson"
    fi
    # Fetch setup
    if [[ ! -d "${CODE_PATH}/gitlab.com/perobertson/setup" ]]; then
        git clone https://gitlab.com/perobertson/setup.git \
            "${CODE_PATH}/gitlab.com/perobertson/setup"
    elif [[ -z "${CMD:-}" ]]; then
        # user reran the curl command
        cd "${CODE_PATH}/gitlab.com/perobertson/setup"
        git pull --rebase --stat
        cd -
    fi
}

switch_dir(){
    # Possible playbook locations:
    # - ${CODE_PATH}/gitlab.com/perobertson/setup
    # - current directory
    if [[ -z "${CMD:-}" ]]; then
        # piped into bash, so use the fetched location
        cd "${CODE_PATH}/gitlab.com/perobertson/setup"
    else
        # otherwise it was invoked from a shell
        HERE="$( cd "$( dirname "${CMD}" )" >/dev/null 2>&1 && pwd )"
        cd "${HERE}"
    fi
}

bootstrap(){
    os="$(. /etc/os-release && echo "${ID:-}")"
    case "${os}" in
        fedora)  source "bootstrap/fedora.bash"  ;;
        ubuntu)  source "bootstrap/ubuntu.bash"  ;;
        *)
            echo "WARNING: ${os} is not supported" >&2
            echo "Please submit an issue at https://gitlab.com/perobertson/setup/issues" >&2
            echo "Attempting to run ansible-playbook anyways..." >&2
        ;;
    esac
}

# Clear any previous sudo permission
sudo -k

# Prevent running as root
# The intent is to update the users configs, not the system
if [[ $(id -u) -eq 0 ]]; then
    echo 'ERROR: This script must be run as a normal user.' >&2
    exit 1
fi

install_git
fetch_setup
switch_dir
bootstrap

# Run the setup
cd playbooks
ansible-galaxy collection install -r config/collections.yml
ansible-playbook -v setup.yml

echo ''
echo 'Everything installed. Be sure to reboot at your earliest convenience'
