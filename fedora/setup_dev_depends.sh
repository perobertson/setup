# Need to upgrade vim first, otherwise there are conflicts
sudo dnf -y upgrade vim-minimal

sudo dnf -y install autoconf \
                    automake \
                    bison \
                    bzip2 \
                    dropbox \
                    dstat \
                    freetype-freeworld \
                    gcc-c++ \
                    git \
                    graphviz \
                    htop \
                    i3 \
                    ImageMagick \
                    levien-inconsolata-fonts \
                    libffi-devel \
                    libtool \
                    libyaml-devel \
                    openssl-devel \
                    p7zip \
                    patch \
                    pygpgme \
                    redhat-lsb \
                    redis \
                    ruby \
                    samba \
                    sl \
                    sqlite-devel \
                    sysstat \
                    readline-devel \
                    vim \
                    wget \
                    zlib-devel \
                    zsh

sudo dnf -y install https://releases.hashicorp.com/vagrant/1.9.2/vagrant_1.9.2_x86_64.rpm

# Common gems that are used all the time
gem install bundler \
            rake

sudo systemctl enable smb
sudo systemctl enable nmb
sudo systemctl enable redis

# Setup PhantomJS
/usr/bin/curl -Lo "$HOME/Downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2" https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar xvjf "$HOME/Downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2" -C "$HOME/Applications"
ln -s "$HOME/Applications/phantomjs-2.1.1-linux-x86_64/bin/phantomjs" "$HOME/bin/phantomjs"
