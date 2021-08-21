#!/bin/bash
while true; do
  mysql -pisucon -uisucon -A isucondition -e "LOAD DATA LOCAL INFILE '/dev/shm/condition.csv' INTO TABLE isucondition.isu_condition FIELDS TERMINATED BY ',' ENCLOSED BY '\"' (\`jia_isu_uuid\`, \`timestamp\`, \`is_sitting\`, \`condition\`, \`message\`);"
  rm -f /dev/shm/condition.csv
  sleep 1
done
