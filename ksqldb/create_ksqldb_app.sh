#!/bin/bash

#################################################################
# Initialization
#################################################################

# Source demo-specific configurations
source config/demo.cfg

#################################################################
# Confluent Cloud ksqlDB application
#################################################################
echo -e "\nConfluent Cloud ksqlDB application endpoint $KSQLDB_ENDPOINT\n"
echo -e "\nRun as workshop et to $run_as_workshop\n"

#ccloud::validate_ksqldb_up "$KSQLDB_ENDPOINT" || exit 1

# Submit KSQL queries
function submit_ksqldb_queries {

echo -e "\nSubmit KSQL queries\n"
properties='"ksql.streams.auto.offset.reset":"earliest","ksql.streams.cache.max.bytes.buffering":"0"'
while read ksqlCmd; do
  echo -e "\n$ksqlCmd\n"
  response=$(curl -X POST $KSQLDB_ENDPOINT/ksql \
       -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
       -u $KSQLDB_BASIC_AUTH_USER_INFO \
       --silent \
       -d @<(cat <<EOF
{
  "ksql": "$ksqlCmd",
  "streamsProperties": {$properties}
}
EOF
))
  echo $response
  if [[ ! "$response" =~ "SUCCESS" ]]; then
    echo -e "\nERROR: KSQL command '$ksqlCmd' did not include \"SUCCESS\" in the response.  Please troubleshoot."
    exit 1
  fi
done <$1
echo -e "\nSleeping 20 seconds after submitting KSQL queries\n"
sleep 20
}

if [ "$run_as_workshop" == "true" ]; then
    echo "Running as workshop, additional ksqlDB queries will not be run"
else
    echo "Running as demo, additional ksqlDB queries will be created by this script now"
    submit_ksqldb_queries ksqldb/statements-demo.sql
fi

exit 0
