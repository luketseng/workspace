#!/bin/bash

# Set variables
MYSQL_CONTAINER_NAME=wordpress_db_1
MYSQL_ROOT_PASSWORD=example
DB_NAME=wordpress
BACKUP_FOLDER=/backup/wp_backup

echo ${MYSQL_CONTAINER_NAME}


# Set backup file name
function set_backup_file_name() {
  export BACKUP_FILE_NAME=mysql_$(date '+%Y%m%d_%H%M%S').sql
}

# Backup MySQL database
backup_mysql() {
  set_backup_file_name
  # Check if the backup folder exists, if not, create it
  if [ ! -d "$BACKUP_FOLDER" ]; then
    mkdir -p "$BACKUP_FOLDER"
  fi

  #echo docker exec $(docker-compose ps -q db) /bin/bash -c 'mysqldump --single-transaction -u root -p"$MYSQL_ROOT_PASSWORD" -B"$DB_NAME"' \> $BACKUP_FOLDER/$BACKUP_FILE_NAME
  echo docker exec ${MYSQL_CONTAINER_NAME} /usr/bin/mysqldump -uroot -p$MYSQL_ROOT_PASSWORD $DB_NAME
  docker exec ${MYSQL_CONTAINER_NAME} /usr/bin/mysqldump -uroot -p$MYSQL_ROOT_PASSWORD $DB_NAME > $BACKUP_FOLDER/$BACKUP_FILE_NAME
  echo "MySQL backup complete: $BACKUP_FOLDER/$BACKUP_FILE_NAME"
}

# Restore MySQL database from SQL file
restore_mysql() {
  local sql_file_name=$1

  #echo docker exec -it $MYSQL_CONTAINER_NAME /bin/bash -c "mysql -uroot -p$MYSQL_ROOT_PASSWORD $DB_NAME" \< $sql_file_name
  #docker exec -i wordpress_db_1 /bin/bash -c "mysql -uroot -pexample wordpress" < /backup/wp_backup/mysql_20230227_092326.sql
  echo docker exec -i ${MYSQL_CONTAINER_NAME} /bin/bash -c "mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${DB_NAME}"
  docker exec -i ${MYSQL_CONTAINER_NAME} /bin/bash -c "mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${DB_NAME}" < ${sql_file_name}
  echo "MySQL restore complete: $sql_file_name"
}

# Main script
if [ "$1" == "backup" ]; then
  backup_mysql
elif [ "$1" == "restore" ]; then
  if [ -z "$2" ]; then
    echo "Error: please provide a SQL file name to restore."
    exit 1
  else
    echo "Restore file: $2"
  fi
  # Check if the restore file exists
  if [ ! -f "$2" ]; then
    echo "Restore file does not exist. Please make sure the file name is correct."
    exit 1
  fi
  restore_mysql $2
else
  echo "Please enter an action: backup or restore"
  echo "Usage: ./wp_db_br.sh [backup|restore sql_file_name]"
  exit 1
fi
