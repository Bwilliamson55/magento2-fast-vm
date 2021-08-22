#!/bin/bash

# Hook on system packages sequence

# Xdebug for php:
echo '--- 010-system-packs.sh ---'
apt-get update -y && apt-get install -y \
php${PROJECT_PHP_VERSION}-xdebug
# Xdebug V3 config
if [[ -z $(grep "${DEBUG_IDEKEY}" "/etc/php/${PROJECT_PHP_VERSION}/mods-available/xdebug.ini") ]]; then
echo "--- Overwriting /etc/php/${PROJECT_PHP_VERSION}/mods-available/xdebug.ini ---"
cat > /etc/php/${PROJECT_PHP_VERSION}/mods-available/xdebug.ini <<-EOF
zend_extension=xdebug.so
xdebug.client_port = 9003
xdebug.max_nesting_level = 512
xdebug.mode=debug
;xdebug.start_upon_error = true
xdebug.idekey = ${DEBUG_IDEKEY}
xdebug.client_host = 10.0.2.2
EOF
fi

# SchemaCrawler

# Modify this for whatever version you're trying to download
_SCH_VERSION='16.15.4'
# Pick your own temp dir
# Note that the zip archive by default creates and unzips into a subdir,
#   e.g. `schemacrawler-15.06.01-distribution`
_TEMPDIR=/tmp

# Pick the path to store the app and the shell script
# NOTE: The parent dir must be writable
_INSTALL_DIR=/home/vagrant/bin/schemacrawler

# The filename stem for the downloadable zip, as it exists on the Github filesystem,
#   and the subdir it creates when unzipped
_SCH_FNAME="schemacrawler-${_SCH_VERSION}-distribution"
_SCH_URL="https://github.com/schemacrawler/SchemaCrawler/releases/download/v${_SCH_VERSION}/${_SCH_FNAME}.zip"
_SCH_ZNAME="${_TEMPDIR}/${_SCH_FNAME}.zip"

# Download and unzip into $_TEMPDIR
mkdir -p ${_TEMPDIR}
printf "\nDownloading\n\t ${_SCH_URL} \n\tinto temporary directory: ${_TEMPDIR}\n\n"
curl -Lo ${_SCH_ZNAME} ${_SCH_URL}
unzip ${_SCH_ZNAME} -d ${_TEMPDIR}
printf "\n\n"
# Download and install python scripting requirements, and all the other things
(cd /tmp/${_SCH_FNAME}/_downloader/ && \
bash download.sh python && \
bash download.sh plugins && \
bash download.sh jackson && \
bash download.sh graphviz && \
bash download.sh javascript && \
bash download.sh ruby)

# Move subdir from release package into install dir
printf "\nMoving contents of /tmp/${_SCH_FNAME}/_schemacrawler/ \n\tinto ${_INSTALL_DIR}\n\n"
mkdir -p ${_INSTALL_DIR}
cp -r /tmp/${_SCH_FNAME}/_schemacrawler/. ${_INSTALL_DIR}

_INSTALL_DIR=/home/vagrant/bin/schemacrawler

echo 'export PATH="$HOME/bin:$PATH"' >> /home/vagrant/.bashrc
echo 'export PATH="/home/vagrant/bin/schemacrawler:$PATH"' >> /home/vagrant/.bashrc

# Python Script for crawler, to spit out mermaid style erDiagrams. Change as needed.

cat > ${_INSTALL_DIR}/erDiagram.py <<'EOF'
from schemacrawler.schema import TableRelationshipType # pylint: disable=import-error
import re

print('erDiagram')
print('')
for table in catalog.tables:
  print('  ' + table.fullName + ' {')
  for column in table.columns:
    print('    ' + re.sub(r'\([\d ,]+\)', '', column.columnDataType.name) + ' ' + column.name)
  print('  }')
  print('')

for table in catalog.tables:  
  for childTable in table.getRelatedTables(TableRelationshipType.child):
    print('  ' + table.name + ' ||--o{ ' + childTable.name + ' : "foreign key"')
  print('')
EOF

chmod +x ${_INSTALL_DIR}/erDiagram.py

#alias in bashrc to quickly run against the above script but also as an example
erDiagramAlias="\"bash ${_INSTALL_DIR}/schemacrawler.sh \
--server=mysql \
--database=${PROJECT_NAME} \
--info-level=standard \
--command=script \
--user=vagrant \
--password=vagrant \
--script-language=python \
--script=${_INSTALL_DIR}/erDiagram.py\""

#Alias to run the erDiagram script
cat <<EOF >> /home/vagrant/.bashrc
alias erDiagram=${erDiagramAlias}
EOF



