#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

sudo dnf -y install \
    pipx \
    python3-devel \
    python3-libdnf5 \
    python3-pip

# Setup ansible
"${SCRIPT_DIR}/install_ansible.bash"

# make sure all dependencies are satisfied
pip3 check
