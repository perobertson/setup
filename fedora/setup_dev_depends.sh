# Need to upgrade vim first, otherwise there are conflicts
sudo dnf -y upgrade vim-minimal
# Install vim separately due to conflicts in upgrade / install
sudo dnf -y install vim

sudo dnf -y install autoconf \
                    automake \
                    bison \
                    bzip2 \
                    dropbox \
                    dstat \
                    freetype-freeworld \
                    gcc \
                    gcc-c++ \
                    git \
                    git-cola \
                    gitk \
                    graphviz \
                    htop \
                    i3 \
                    ImageMagick \
                    levien-inconsolata-fonts \
                    libcurl-devel \
                    libffi-devel \
                    libtool \
                    libyaml-devel \
                    make \
                    memcached \
                    nodejs \
                    openssl-devel \
                    p7zip \
                    patch \
                    perl \
                    pygpgme \
                    python-devel \
                    redhat-lsb \
                    redhat-rpm-config \
                    redis \
                    ruby \
                    ruby-devel \
                    samba \
                    sl \
                    sqlite-devel \
                    sublime-text \
                    sysstat \
                    readline-devel \
                    wget \
                    zlib-devel \
                    zsh

pip install --user --upgrade pip
pip install --user virtualenv

if ! hash vagrant || [ "$(vagrant --version)" != 'Vagrant 2.0.0' ]; then
  sudo dnf -y install https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.rpm
fi

# Common gems that are used all the time
gem install bundler \
            rake

sudo systemctl enable smb
sudo systemctl enable nmb
sudo systemctl enable memcached
sudo systemctl enable redis

# Setup PhantomJS
[[ ! -f "$HOME/Downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2" ]] && /usr/bin/curl -Lo "$HOME/Downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2" https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
[[ ! -d "$HOME/Applications/phantomjs-2.1.1-linux-x86_64" ]] && tar xvjf "$HOME/Downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2" -C "$HOME/Applications"
if [[ -f "$HOME/bin/phantomjs" ]]; then
  rm "$HOME/bin/phantomjs"
else
  ln -s "$HOME/Applications/phantomjs-2.1.1-linux-x86_64/bin/phantomjs" "$HOME/bin/phantomjs"
fi

# Setup Heroku CLI
[[ ! -f "$HOME/Downloads/heroku.tar.gz" ]] && wget https://cli-assets.heroku.com/heroku-cli/channels/stable/heroku-cli-linux-x64.tar.gz -O "$HOME/Downloads/heroku.tar.gz"
mkdir -p "$HOME/Downloads/heroku"
# Heroku is annoying and does not put the version in the url so we have no idea what version just got downloaded
# Use globbing to get around that
tar -xzf "$HOME/Downloads/heroku.tar.gz" -C "$HOME/Downloads/heroku/"
mv "$HOME/Downloads/heroku/"* "$HOME/Applications/heroku/"
if [[ -f "$HOME/bin/heroku" ]]; then
  rm "$HOME/bin/heroku"
else
  ln -s "$HOME/Applications/heroku/bin/heroku" "$HOME/bin/heroku"
fi
