#!/bin/bash
DB_USER=''
DB_NAME=''
DB_PASS=''
DB_HOST=''

today=$(date +%Y-%m-%d)
echo "Today's date is: $today"
ls -lh "$WORKSPACE"

BACKUP_DIR="$WORKSPACE"
RETENTION_DAYS=7

start_time=$(date +%s.%N)
TIMESTAMP=$(date "+%Y-%m-%d_%H")
CURRENT_BACKUP_DIR="$BACKUP_DIR/$DB_NAME_backup_$TIMESTAMP"
mkdir -p "$CURRENT_BACKUP_DIR"

echo "+ mydumper"
mydumper \
  -u $DB_USER \
  -p "$DB_PASS" \
  -h $DB_HOST \
  -B $DB_NAME \
  -t 4 \
  -c \
  --statement-size=1000000 \
  --long-query-guard 3600 \
  --rows=50000 \
  -o "$CURRENT_BACKUP_DIR" || {
    echo "ERROR: Can't do mydumper backup"
    rm -rf "$CURRENT_BACKUP_DIR"
    exit 1
}gi

end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
echo "Backup execution time: $execution_time seconds"

tar czf "$CURRENT_BACKUP_DIR.tar.gz" "$CURRENT_BACKUP_DIR" && rm -rf "$CURRENT_BACKUP_DIR"

find "$BACKUP_DIR" -name "backup_*" -type f -mtime +$RETENTION_DAYS -exec rm {} \;