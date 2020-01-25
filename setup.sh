#!/usr/bin/env bash
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

# Set the path here so that any commands we install in user space will be available during setup
# This is setup in the dotfiles, but we also need it here for setup
PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Clear any previous sudo permission
sudo -k

# Check for root
if [[ $(id -u) -eq 0 ]]; then
    echo 'script must be run as a normal user'
    exit 1
fi

# Set up app directories
mkdir -pv "$HOME/Applications" "$HOME/Downloads" "$HOME/bin" "$HOME/workspace"

# Check if git needs installed
if [[ ! -x "$(command -v git)" ]]; then
    if [[ -x "$(command -v dnf)" ]]; then
        sudo dnf install -y git
    else
        sudo apt-get update
        sudo apt-get install -y apt-transport-https
        sudo apt-get install -y git
    fi
fi

# Setup ssh
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi
if [[ "$(grep ^gitlab.com "$HOME/.ssh/known_hosts")" = '' ]]; then
    ssh-keyscan 'gitlab.com' >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi
if [[ "$(grep ^github.com "$HOME/.ssh/known_hosts")" = '' ]]; then
    ssh-keyscan 'github.com' >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

# Fetch the scripts
if [[ ! -d "$HOME/Applications/scripts" ]]; then
    git clone https://gitlab.com/perobertson/scripts.git "$HOME/Applications/scripts"
    cd "$HOME/Applications/scripts"

    if [[ -n "${CI:-}" ]]; then
        # if we are in CI, then checkout the specific version for testing
        git reset --hard "${CI_COMMIT_SHA}"
    fi
fi

# Run the setup
os="$(. /etc/os-release && echo "$ID")"
case "${os}" in
    fedora) . "fedora/bootstrap.sh" ;;
    ubuntu) . "ubuntu/bootstrap.sh" ;;
    *)
        echo "WARN: ${os} is not supported"
        echo "Please submit an issue at https://gitlab.com/perobertson/scripts/issues"
        echo "Attempting to run ansible-playbook anyways..."
    ;;
esac

ansible-playbook -v setup.yml
if [[ -z "${CI:-}" ]]; then
    # only start the services when outside of docker
    ansible-playbook -v -t systemd setup.yml
fi

echo ''
echo 'Everything installed. Be sure to reboot at your earliest convenience'
