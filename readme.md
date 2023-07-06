# Tote pool poc

Eventsource pattern used to form a tote pool. 

The main input topic `tote_win_bets` is keyed into two new streams which are used to form pools based around that key.

`tote_win_bets_runner_keyed` -> `tote_runners_pool`

`tote_win_bets_race_keyed` -> `tote_race_pool`

Then a N-way join on the intial unpartitioned streamd and the two pool tables to form the totes odds stream.

`tote_win_bets` | `tote_runners_pool` | `tote_race_pool` -> `tote_win_bet_race_runners_odds`


### Diagram
![alt ksqldb flow](totes_ksqldb_poc.png)


### Considerations;
* The two pool tables don't broadcast changes down stream, there is a eventual consistence concept at play. 
* The updates to the `tote_win_bets` seem to be behind one step, this doesn't effect the results, it is mearly how table and stream joins work - so the order of events will resolve. 
* Close off each race and runner zero amount bet to step the final stream foward and make it complete. As show below or via kssqldb cli;

```
{
      "topic": "tote_win_bets",
      "key": null,
      "value": {
        "runner_uid": 1,
        "race_uid": 0,
        "amount": 0
      }
    }
 ```   

### Install and run
`bash install.sh`
To install any missing dependencies. Including makefile.

`make start`
To run the docker containers.

`make build` | `bash build.sh`
To build the streams and tables, the makefile has the permissions added.

`make cli`
To start the ksqlDB CLI. Open a new terminal window for this. 

Once you have build the streams and tables a nice way of running a demo is to run a pull query in `ksqldb-cli` on the final stream `tote_win_bet_race_runners_odds` like;

`SELECT * FROM tote_win_bet_race_runners_odds WHERE race_id = 0 EMIT CHANGES;` 

This will continously print to console changes to that stream.

`make play` | `bash play.sh`
To insert the queries, for demo purpose, the makefile has the permissions added. If you 



`make kill`
To kill the running docker

`make prune`
To remove any instances and volumes, good for clearing streams or if you have made structural changes during development.

`make test`
tbc

### Useful queries

`SHOW STREAMS;`
`SHOW TABLES;` | `LIST TABLE;`
`SHOW queries;`
`DESCRIBE table | stream;`
Details of that steam or table, including type of data.

`PRINT 'topic' FROM BEGINNING INTERVAL 1;`
A way of seeing the output.

`DROP TABLE table_name;` 
`DROP STREAM table_name;` 
You will need to terminate any querys creating the table first;

`TERMINATE query_id;` 
