#!/bin/bash

# Hook on system init sequence

# Example:
# cat <<EOF >> /etc/profile.d/myvars.sh
# export CUSTOM_ENVIRONMENT=myvalue
# EOF

# Profile Tools
echo '--- 001-env.sh ---'

if [[ -z $(grep "magento-tools-etc" "/home/vagrant/.bashrc") ]]; then
mkdir /home/vagrant/dbdump
echo '--- Appending bashrc ---'
cat <<'EOF' >> /home/vagrant/.bashrc
#magento-tools-etc
#General

#tar extract filename to directory
#e.g. restore-tar ~/tarname.tar.gz ~/myExtractedFolder
function restore-tar() {
    filename=${1:?"The file path must be specified."}
    directory=${2:?"The destination folder must be specified."}   
    tar -xzvf $filename -C $directory
}

export EDITOR=nano
export VISUAL="$EDITOR"
#

#ElasticSearch and Mysql
alias check-elastic='curl -XGET "localhost:9200/_cluster/health?pretty"'
alias mysql-root='mysql -h 127.0.0.1 -u root'
alias mysqldump-magento="mysqldump ${PROJECT_NAME} -u vagrant -p -h 127.0.0.1 | gzip > ~/dbdump/${PROJECT_NAME}_$(date "+%Y-%m-%d_%H%M").sql.gz"

#zcat a gzip sql file into specified db
#e.g. restore-db ~/dbdump/myfile.sql.gz magentoDBname
function restore-db() {
    dbfile=${1:?"The path must be specified."}
    dbname=${2:?"The destination db name must be specified."}   
    zcat $dbfile | mysql -h 127.0.0.1 -u vagrant -p $dbname
}
#

#Magento time savers

##Removing things
alias flush-static='rm -rf pub/static/* ||: && rm -rf var/view_preprocessed/* ||: && rm -rf var/cache/* ||: && rm -rf var/page_cache/* ||:'
alias nuke-compile='rm -rf generated/* ||: && rm -rf pub/static/* ||: && rm -rf var/view_preprocessed/* ||: && rm -rf var/cache/* ||: && rm -rf var/page_cache/* ||: && bin/magento set:up && php -dmemory_limit=4G bin/magento setup:di:compile && bin/magento c:c'
alias nuke-mage='rm -rf generated/* ||: && rm -rf pub/static/* ||: && rm -rf var/view_preprocessed/* ||: && rm -rf var/page_cache/* ||: && rm -rf var/cache/* ||:'

##Cache things
alias c:c='bin/magento c:c'
alias c:f='bin/magento c:f'

##Compile and Deploy things
alias compile-mage='bin/magento set:up && php -dmemory_limit=4G bin/magento setup:di:compile && bin/magento c:c'
alias compile-mage-kg='bin/magento set:up --keep-generated && php -dmemory_limit=4G bin/magento setup:di:compile && bin/magento set:static-content:deploy -f && bin/magento c:c'
alias deploy-static='bin/magento set:static-content:deploy -f'

##Aliases for Aliases
alias set:up='bin/magento set:up'
alias di:compile='php -d memory_limit=4G bin/magento setup:di:compile'

#Git things
alias fpg='git fetch && git pull'

EOF
fi