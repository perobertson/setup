#!/usr/bin/env bash
set -xueo pipefail

# Make sure the PATH has the location of rust and python bins
# cargo/bin is needed for distros that need to use rustup.sh
PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:${HOME}/bin:${PATH}"

# Check the version of installed tools
1password --version || echo '1password unavailable'
bash --version
bat --version || echo 'bat unavailable'
curl --version
docker --version || echo 'docker unavailable'
docker compose version || echo 'docker compose unavailable'
docker-compose version || echo 'docker-compose unavailable'
exa --version || echo 'exa unavailable'
fd --version || echo 'fd unavailable'
flameshot --version || echo 'flameshot unavailable'
flatpak --version
gcc --version
git --version
gitui --version || echo 'gitui unavailable'
go-task --version
gzip --version
jq --version
make --version
node --version
npm --version
op --version || echo 'op unavailable'
pip --version
podman --version
podman-compose --version || echo 'podman-compose unavailable'
python --version || echo 'python unavailable'
python3 --version
shellcheck --version || echo 'shellcheck unavailable'
ssh -V
tar --version
tree --version
unzip -v
wget --version
xz --version
ykman --version || echo 'ykman unavailable'
zoxide --version || echo 'zoxide unavailable'
zsh --version
zstd --version
# These commands do not have a version option or cause side effects
command -v ansible
command -v code
command -v gitk

# Use rustup.sh instead of installing these on the system.
# It allows for other toolchains to be installed in the future.
# command -v cargo
# command -v cargo-clippy
# command -v rust-gdb
# command -v rustc
# command -v rustdoc
# command -v rustfmt
# command -v rustup.sh
