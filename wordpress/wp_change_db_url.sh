#!/bin/bash

# Replace the URL of WordPress in the database from the old URL to the new URL.
# Container name, please replace it with your own
wordpress_container_name=wordpress_db_1

# old URL
old_url="http://192.168.10.19:8000"
#old_url="http://zane.myftp.org:8000"

# new URL
new_url="http://zane.myftp.org:8000"
#new_url="http://192.168.10.19:8001"

# MySQL database settings
db_user="wordpress"
db_password="wordpress"
tb_name="wordpress"

# Update the meta_value in the wp_postmeta table with the new URL
docker exec -it ${wordpress_container_name} mysql -u$db_user -p$db_password -D$tb_name -e "UPDATE wp_options SET option_value = replace(option_value, '$old_url', '$new_url') WHERE option_name = 'home' OR option_name = 'siteurl';"
docker exec -it ${wordpress_container_name} mysql -u$db_user -p$db_password -D$tb_name -e "UPDATE wp_posts SET guid = replace(guid, '$old_url','$new_url');"
docker exec -it ${wordpress_container_name} mysql -u$db_user -p$db_password -D$tb_name -e "UPDATE wp_posts SET post_content = replace(post_content, '$old_url', '$new_url');"
docker exec -it ${wordpress_container_name} mysql -u$db_user -p$db_password -D$tb_name -e "UPDATE wp_postmeta SET meta_value = replace(meta_value,'$old_url','$new_url');"
