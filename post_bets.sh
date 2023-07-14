curl -X POST \
  -H "Content-Type: application/vnd.kafka.avro.v2+json" \
  -H "Accept: application/vnd.kafka.v2+json" \
  -g --data '{
    "value_schema_id": 1,
    "records": [
      {
        "value": {
          "RUNNER_ID": {"int": 1},
          "RACE_ID": {"int": 0},
          "AMOUNT": {"double": 25.0}
        }
      },
      {
        "value": {
          "RUNNER_ID": {"int": 1},
          "RACE_ID": {"int": 0},
          "AMOUNT": {"double": 50.0}
        }
      }
    ]
  }' \
  "http://localhost:8082/topics/tote_win_bets" | jq
