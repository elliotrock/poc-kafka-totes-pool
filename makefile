.PHONY: cli 
cli:
	docker exec -it ksqldb-cli ksql http://ksqldb-server:8088	

.PHONY: play
play:
	chmod u+x play.sh
	bash play.sh

.PHONY: build
build:
	chmod u+x build.sh
	bash build.sh

# deprecated
.PHONY: test
test:
	# docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input.json -s opt/app/src/statements.sql -o /opt/app/test/output-runners-pool.json
	# docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input.json -s opt/app/src/statements.sql -o /opt/app/test/output-race-pool.json
	# docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input.json -s opt/app/src/statements.sql -o /opt/app/test/output-bets-runners-pool.json	
	
	# docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input-runners.json -s opt/app/src/statements-race-runners.sql -o /opt/app/test/output-race-runners.json
	# docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input.json -s opt/app/src/statements.sql -o /opt/app/test/output-race-runners-odds.json

.PHONY: start
start: 
	docker-compose up

.PHONY: stop
stop: 
	docker-compose stop

.PHONY: kill
kill: 
	docker-compose kill

.PHONY: prune
prune: 
	docker container prune