#!/bin/bash
image="gvenzl/oracle-free"
tag="slim"


echo "Setup is starting: Oracle DB"

# Check docker is installed?
echo -ne "[1] Docker check:\t"
if ! docker info > /dev/null 2>&1; then
  echo "Error - Docker is not installed!"
  exit 1
else echo "Success - Docker is installed."
fi


echo -ne "[2] Pull docker image:\t"
# Check image exists?
if [[ "$(docker images -q $image:$tag 2> /dev/null)" == "" ]]; then
  echo "$image:$tag"
  docker pull "$image:$tag"
else 
    echo "$image:$tag already exists."
fi

echo "[3] Start Container:"


docker run --name oracledb-harness-copilot \
          -p 1523:1521 \
          -e ORACLE_PASSWORD="tdsys" \
          -v `pwd -W`/oracle-volume:/opt/oracle/oradata \
          -v `pwd -W`/scripts:/container-entrypoint-initdb.d \
      "$image:$tag"

exit 1