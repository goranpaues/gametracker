#!/bin/bash
echo "NOTE: Java needs to be installed for this script to succeed!"
echo "NOTE: Ensure that the Oracle Docker image has been installed by the start.sh script"

echo Restarting database just in case...
docker stop oracledb-harness-copilot
docker start oracledb-harness-copilot

echo "Copying grouvee_export.json to the Oracle volume."
cp -f grouvee_export.json oracle-volume/grouvee_export.json

echo "Downloading sqlcl..."
curl -Lk "https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip" -o sqlcl.zip
unzip -q sqlcl.zip

echo "Synchronizing Oracle AI DB skills..."
MSYS_NO_PATHCONV=1 ./sqlcl/bin/sql /nolog <<EOF
skills sync --verbose --skill-name db
exit
EOF

echo "Downloading utPLSQL..."
# Get the url to latest release "zip" file
UTPLSQL_DOWNLOAD_URL=$(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip\"" | sed 's/"//g')
# Download the latest release "zip" file
curl -Lk "${UTPLSQL_DOWNLOAD_URL}" -o utPLSQL.zip
# Extract downloaded "zip" file
unzip -q utPLSQL.zip

echo "Starting installation of utPLSQL..."
./sqlcl/bin/sql -s sys/SystemSYS123456#@localhost:1523/FREEPDB1 as sysdba @utPLSQL/source/install_headless.sql utplsql utplsql gametracker
