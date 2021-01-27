-- SET 'auto.offset.reset' = 'earliest';

CREATE STREAM tote_win_bets (runner_id INT, race_id INT, amount DOUBLE)
    WITH (kafka_topic='tote_win_bets', partitions=1, value_format = 'avro');

-- Bets runner keyed by partition
CREATE STREAM tote_win_bets_runner_keyed 
    AS SELECT tote_win_bets.runner_id as runner_id, tote_win_bets.race_id as race_id, amount 
    FROM tote_win_bets
    PARTITION BY runner_id;     

-- Bets race keyed by partition
CREATE STREAM tote_win_bets_race_keyed
    AS SELECT tote_win_bets.race_id as race_id, tote_win_bets.amount as amount
    FROM tote_win_bets
    PARTITION BY race_id;

-- Runner Pool MAX(race_id) as race_id
CREATE TABLE tote_runners_pool 
    AS SELECT runner_id, SUM(amount) as runner_pool_amount 
    FROM tote_win_bets_runner_keyed GROUP BY runner_id; 

-- Race Pool
CREATE TABLE tote_race_pool 
    AS SELECT race_id, SUM(amount) as race_pool_amount 
    FROM tote_win_bets_race_keyed GROUP BY race_id; 

-- form 3 way join odd stream
CREATE STREAM tote_win_bet_race_runners_odds AS
    SELECT tote_race_pool.race_id as race_id,
        tote_runners_pool.runner_id as runner_id,
        tote_runners_pool.runner_pool_amount as runner_pool_amount,
        tote_race_pool.race_pool_amount as race_pool_amount,
        (tote_race_pool.race_pool_amount / tote_runners_pool.runner_pool_amount) as odds
        FROM tote_win_bets
        INNER JOIN tote_runners_pool ON tote_win_bets.runner_id = tote_runners_pool.runner_id   
        INNER JOIN tote_race_pool ON tote_win_bets.race_id = tote_race_pool.race_id
    EMIT CHANGES;  

-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (1, 0, 25);
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (1, 0, 50);
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (1, 0, 50);
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (2, 0, 5);
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (2, 0, 10);
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (2, 0, 20); 
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (2, 0, -20);
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (2, 0, 0);
-- INSERT INTO tote_win_bets (runner_id, race_id, amount) VALUES (1, 0, 0);    