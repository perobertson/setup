# Setup Postgres
sudo dnf -y install postgresql \
                    postgresql-contrib \
                    postgresql-devel \
                    postgresql-server
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo su --command="perl -p -i -e 's/host([\w :\/\.]*)ident/host\$1trust/g' /var/lib/pgsql/data/pg_hba.conf" --login postgres
sudo su --command="psql --command='CREATE ROLE $(whoami) WITH SUPERUSER LOGIN;'" --login postgres

# Setup MySql
# sudo dnf -y install mariadb \
#                     mariadb-devel \
#                     mariadb-server \
#                     expect
# sudo systemctl start mariadb
# sudo systemctl enable mariadb

# SECURE_MYSQL=$(expect -c "
#   set timeout 10
#   spawn mysql_secure_installation
#   expect \"Enter current password for root (enter for none):\"
#   send \"\r\"
#   expect \"Change the root password?\"
#   send \"n\r\"
#   expect \"Remove anonymous users?\"
#   send \"y\r\"
#   expect \"Disallow root login remotely?\"
#   send \"y\r\"
#   expect \"Remove test database and access to it?\"
#   send \"y\r\"
#   expect \"Reload privilege tables now?\"
#   send \"y\r\"
#   expect eof
# ")
# echo "$SECURE_MYSQL"
# unset SECURE_MYSQL
