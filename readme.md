** Tote pool poc

** Install and run
``make install``
To install any missing dependencies.

``make start``
To run the docker containers.

** useful queries

`SHOW STREAMS;`
`SHOW TABLES;` | `LIST TABLE;`
`SHOW queries;`
`DESCRIBE table | stream;`
Details of that steam or table, including type of data.

`DROP TABLE table_name;` 
`DROP STREAM table_name;` 
You will need to terminate any querys creating the table first;

`TERMINATE query_id;` 
