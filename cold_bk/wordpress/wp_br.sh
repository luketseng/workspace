#!/bin/bash

# Set variables
wordpress_container_name=wordpress_wordpress_1
BACKUP_FOLDER=/backup/wp_backup


# Set backup file name
function set_backup_file_name() {
  export exported_file_name=wordpress_$(date '+%Y%m%d_%H%M%S').xml
}

backup_wordpress() {
  set_backup_file_name
  # Check if the backup folder exists, if not, create it
  if [ ! -d "$BACKUP_FOLDER" ]; then
    mkdir -p "$BACKUP_FOLDER"
  fi

  # Backup WordPress posts
  docker exec "$wordpress_container_name" /bin/bash -c "wp export --allow-root --stdout > /tmp/wordpress.xml"
  docker cp "$wordpress_container_name:/tmp/wordpress.xml" "$BACKUP_FOLDER/$exported_file_name"

  # Backup WordPress configuration
  docker cp "$wordpress_container_name:/var/www/html/wp-config.php" "$BACKUP_FOLDER/"

  echo "WordPress backup completed!"
}

restore_wordpress() {
  local xml_file_name=$1

  # Restore WordPress posts
  docker cp "$xml_file_name" "$wordpress_container_name:/tmp/wordpress.xml"
  docker exec "$wordpress_container_name" wp plugin install wordpress-importer --activate --allow-root
  docker exec "$wordpress_container_name" wp import --authors=create --allow-root /tmp/wordpress.xml

  # Restore WordPress configuration
  docker cp $BACKUP_FOLDER/wp-config.php $wordpress_container_name:/var/www/html/

  # Modify website URL
  #echo "Please enter your website URL (e.g. http://example.com):"
  #read site_url
  #docker exec "$wordpress_container_name" wp search-replace "http://localhost" "$site_url" --allow-root

  echo "WordPress restore completed!"
}

if [ "$1" == "backup" ]; then
  backup_wordpress
elif [ "$1" == "restore" ]; then
  if [ -n "$2" ]; then
    echo "Restore file: $2"
  else
    echo "Error: please provide a XML file name to restore."
    exit 1
  fi
  # Check if the restore file exists
  if [ ! -f "$2" ]; then
    echo "Restore file does not exist. Please make sure the file name is correct."
    exit 1
  fi
  restore_wordpress $2
else
  echo "Please enter an action: backup or restore"
  echo "Usage: ./wp_br.sh [backup|restore xml_file_name]"
  exit 1
fi
