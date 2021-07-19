#!/bin/bash

BACKUPDIR="backup"
CONFIGDIR="/ot-node/data"
CONTAINER_NAME="otnode2"

temp_folder=$BACKUPDIR

for file in `ls ${BACKUPDIR}`; do
    if [ ! ${file}] == "arangodb" ]
    then
      sourcePath="${BACKUPDIR}/${file}"
      destinationPath="${CONTAINER_NAME}:${CONFIGDIR}/"

      sourcePath=./${temp_folder}/${file}
      echo "docker cp ${sourcePath} ${destinationPath}"
      docker cp ${sourcePath} ${destinationPath}
    fi
done

sourcePath="${BACKUPDIR}/.origintrail_noderc"
destinationPath="${CONTAINER_NAME}:/ot-node/current/"

sourcePath=./${temp_folder}/.origintrail_noderc

echo "docker cp ${sourcePath} ${destinationPath}"
docker cp ${sourcePath} ${destinationPath}

identitiesDir="${BACKUPDIR}/identities"
if [ -d ${identitiesDir} ]
then
  sourcePath="${BACKUPDIR}/identities"
  destinationPath="${CONTAINER_NAME}:${CONFIGDIR}/"

  sourcePath=./${temp_folder}/identities
  echo "docker cp ${sourcePath} ${destinationPath}"
  docker cp ${sourcePath} ${destinationPath}
fi

certFiles=(fullchain.pub privkey.pem)
if [ -e "${BACKUPDIR}/fullchain.pem" ] && [ -e "${BACKUPDIR}/privkey.pem" ]
then
	echo "mkdir ${temp_folder}/certs"
	mkdir ${temp_folder}/certs

	echo "cp ${BACKUPDIR}/fullchain.pem ./${temp_folder}/certs/"
	cp ${BACKUPDIR}/fullchain.pem ./${temp_folder}/certs

	echo "cp ${BACKUPDIR}/privkey.pem ./${temp_folder}/certs/"
	cp ${BACKUPDIR}/privkey.pem ./${temp_folder}/certs

	echo "docker cp ${temp_folder}/certs ${CONTAINER_NAME}:/ot-node/"
	docker cp ${temp_folder}/certs otnode:/ot-node/
else
	echo "Cert files do not exits, skipping..."
fi

migrationDir="${BACKUPDIR}/migrations"
if [ -d ${migrationDir} ]
then
  sourcePath="${BACKUPDIR}/migrations"
  destinationPath="${CONTAINER_NAME}:${CONFIGDIR}/"

  sourcePath=./${temp_folder}/migrations
  echo "docker cp ${sourcePath} ${destinationPath}"
  docker cp ${sourcePath} ${destinationPath}
fi

echo docker cp ${CONTAINER_NAME}:/ot-node/current/config/config.json ./
docker cp ${CONTAINER_NAME}:/ot-node/current/config/config.json ./

rm config.json

databaseName=$(cat ${BACKUPDIR}/arangodb/database.txt)
echo "database name ${databaseName}"

databaseUsername=$(cat ${BACKUPDIR}/arangodb/username.txt)
echo "database username ${databaseUsername}"

echo "docker cp ${temp_folder}/arangodb ${CONTAINER_NAME}:${CONFIGDIR}/"
docker cp "${temp_folder}/arangodb" ${CONTAINER_NAME}:${CONFIGDIR}/


echo rm -rf ${temp_folder}
rm -rf ${temp_folder}

echo docker start ${CONTAINER_NAME}
docker start ${CONTAINER_NAME}

echo sleep 30
sleep 30

docker cp ${CONTAINER_NAME}:${CONFIGDIR}/arango.txt arango.txt
databasePassword=$(cat arango.txt)
rm arango.txt

echo "docker exec ${CONTAINER_NAME} arangorestore --server.database ${databaseName} --server.username ${databaseUsername} --server.password \"${databasePassword}\" --input-directory ${CONFIGDIR}/arangodb/ --overwrite true"
docker exec ${CONTAINER_NAME} arangorestore --server.database ${databaseName} --server.username ${databaseUsername} --server.password "${databasePassword}" --input-directory ${CONFIGDIR}/arangodb/ --overwrite true

echo docker restart ${CONTAINER_NAME}
docker restart ${CONTAINER_NAME}

echo docker exec ${CONTAINER_NAME} rm -rf ${CONFIGDIR}/arangodb
docker exec ${CONTAINER_NAME} rm -rf ${CONFIGDIR}/arangodb