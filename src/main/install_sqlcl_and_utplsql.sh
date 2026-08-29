#!/bin/bash
echo "NOTE: Java needs to be installed for this script to succeed!"

echo Setting sys password...
docker exec oracledb-slim resetPassword SystemSYS123456#

echo "Downloading sqlcl..."
curl -Lk "https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip" -o sqlcl.zip
unzip -q sqlcl.zip

echo "Downloading utPLSQL..."
# Get the url to latest release "zip" file
UTPLSQL_DOWNLOAD_URL=$(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip\"" | sed 's/"//g')
# Download the latest release "zip" file
curl -Lk "${UTPLSQL_DOWNLOAD_URL}" -o utPLSQL.zip
# Extract downloaded "zip" file
unzip -q utPLSQL.zip

echo "Starting installation of utPLSQL..."
./sqlcl/bin/sql  sys/SystemSYS123456#@localhost:1521/FREEPDB1 as sysdba @utPLSQL/source/install_headless.sql utplsql utplsql gametracker
