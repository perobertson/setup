#!/usr/bin/env bash
set -euo pipefail
cleanup(){
    /usr/bin/rm -rf /tmp/aws
    /usr/bin/rm /tmp/awscli-exe-linux-x86_64.zip.sig
    /usr/bin/rm /tmp/awscli-exe-linux-x86_64.zip
}
trap cleanup EXIT ERR

cd /tmp

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions
# This is AWSs signing key
if ! gpg -k FB5DB77FD5C118B80511ADA8A6310ACC4672475C > /dev/null; then
    gpg --receive-keys FB5DB77FD5C118B80511ADA8A6310ACC4672475C
fi

/usr/bin/curl -O "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
/usr/bin/curl -O "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig"
/usr/bin/gpg --verify /tmp/awscli-exe-linux-x86_64.zip.sig /tmp/awscli-exe-linux-x86_64.zip
/usr/bin/unzip /tmp/awscli-exe-linux-x86_64.zip

if [[ -x /usr/local/bin/aws ]]; then
    sudo /tmp/aws/install --update
else
    sudo /tmp/aws/install
fi
/usr/local/bin/aws --version
