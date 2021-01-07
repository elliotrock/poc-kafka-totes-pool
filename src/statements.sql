-- SET 'auto.offset.reset' = 'earliest';

CREATE STREAM tote_win_bets (runner_uid INT, race_uid INT, amount DOUBLE)
    WITH (kafka_topic='tote_win_bets', partitions=1, value_format = 'avro');

-- Bets runner keyed by partition
CREATE STREAM tote_win_bets_runner_keyed 
    WITH (kafka_topic='tote_win_bets_runner_keyed', value_format='avro')
    AS SELECT runner_uid, race_uid, amount 
    FROM tote_win_bets
    PARTITION BY runner_uid;     

-- Bets race keyed by partition
CREATE STREAM tote_win_bets_race_keyed
    WITH (kafka_topic='tote_win_bets_race_keyed', value_format='avro')
    AS SELECT race_uid, amount 
    FROM tote_win_bets
    PARTITION BY race_uid;

-- Runner Pool MAX(race_uid) as race_uid
CREATE TABLE tote_runners_pool WITH (kafka_topic='tote_runners_pool', value_format='avro') 
    AS SELECT runner_uid, MAX(race_uid) as race_uid, SUM(amount) as runner_pool_amount 
    FROM tote_win_bets_runner_keyed GROUP BY runner_uid; 

-- Race Pool
CREATE TABLE tote_race_pool WITH (kafka_topic='tote_race_pool', value_format='avro')
    AS SELECT race_uid, SUM(amount) as race_pool_amount 
    FROM tote_win_bets_race_keyed GROUP BY race_uid; 

-- Join 'table' tote_runners_pool with 'stream' tote_win_bets_runner_keyed into a stream
-- CREATE STREAM tote_race_runners_pool WITH 
--     (kafka_topic='tote_race_runners_pool', value_format='avro') AS
--     SELECT tote_runners_pool.race_uid as race_uid,
--     tote_runners_pool.runner_uid as runner_uid, 
--     tote_runners_pool.runner_pool_amount as runner_pool_amount  
--     FROM tote_win_bets_runner_keyed INNER JOIN tote_runners_pool 
--     ON tote_win_bets_runner_keyed.runner_uid = tote_runners_pool.runner_uid
--     PARTITION BY tote_runners_pool.race_uid
--  EMIT CHANGES;

-- CREATE STREAM tote_race_runners_pool WITH 
--     (kafka_topic='tote_race_runners_pool', value_format='avro') AS
--     SELECT race_uid, runner_uid, runner_pool_amount  
--     FROM tote_runners_pool 
--  EMIT CHANGES;

-- form 3 way join odd stream
CREATE STREAM tote_win_bet_race_runners_odds AS
    SELECT tote_race_pool.race_uid as race_uid,
        tote_runners_pool.runner_uid as runner_uid,
        tote_runners_pool.runner_pool_amount as runner_pool_amount,
        tote_race_pool.race_pool_amount as race_pool_amount,
        (tote_race_pool.race_pool_amount / tote_runners_pool.runner_pool_amount) as odds
        FROM tote_win_bets
        INNER JOIN tote_runners_pool ON tote_win_bets.runner_uid = tote_runners_pool.runner_uid   
        INNER JOIN tote_race_pool ON tote_win_bets.race_uid = tote_race_pool.race_uid
    EMIT CHANGES;  

-- form table grouped by race_uid

CREATE TABLE tote_win_bet_race_runners_odds_table 
    WITH (kafka_topic='tote_win_bet_race_runners_odds_table', value_format='avro') AS
    SELECT race_uid, MAX(runner_uid), runner_pool_amount, race_pool_amount, odds
        FROM tote_win_bet_race_runners_odds GROUP BY race_uid; 

-- form odds stream 
-- CREATE STREAM tote_win_bet_race_runners_odds AS
--     SELECT tote_race_runners_pool.race_uid as race_uid,
--         tote_race_runners_pool.runner_uid as runner_uid,
--         tote_race_runners_pool.runner_pool_amount as runner_pool_amount,
--         tote_race_pool.race_pool_amount as race_pool_amount,
--         (tote_race_pool.race_pool_amount / tote_race_runners_pool.runner_pool_amount) as odds
--         FROM tote_race_runners_pool INNER JOIN tote_race_pool 
--         ON tote_race_runners_pool.race_uid = tote_race_pool.ROWKEY
--     EMIT CHANGES;   

-- INSERT INTO tote_win_bets (runner_uid, race_uid, amount) VALUES (1, 0, 25);
-- INSERT INTO tote_win_bets (runner_uid, race_uid, amount) VALUES (1, 0, 50);
-- INSERT INTO tote_win_bets (runner_uid, race_uid, amount) VALUES (2, 0, 5);
    