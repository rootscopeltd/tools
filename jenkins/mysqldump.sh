#!/bin/bash

DB_USER=''
DB_NAME=''
DB_PASS=''
DB_HOST=''

today=$(date +%Y-%m-%d)
echo "Today's date is: $today"
ls -lh "$WORKSPACE"

start_time=$(date +%s.%N)

echo "+ mysqldump"
mysqldump --quick --single-transaction --max_allowed_packet=512M -u $DB_USER --password="$DB_PASS" --databases $DB_NAME --lock-tables=false --host=$DB_HOST | gzip > "$WORKSPACE"/"DB_NAME"_`date "+%Y-%m-%d_%H"`.sql.gz || {
    echo "ERROR: Can't do mysqldump"
    exit 1
}

end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
echo "Backup execution time: $execution_time seconds"

echo "+ after"
ls -lh "$WORKSPACE"

echo "+ cd $WORKSPACE"
cd "$WORKSPACE"

echo "+ find *.gz -mtime +7"
find *.gz -mtime +5

echo "+ find *.gz -mtime +7 -delete"
find *.gz -mtime +5 -delete