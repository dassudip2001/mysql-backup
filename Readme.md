# README

docker run -d --name mysql-backup \
 -e MYSQL_ROOT_PASSWORD=your_password \
 -e MYSQL_DATABASE=your_database \
 -v /path/to/local/backup:/backup \
 mysql-backup
