DROP TABLE IF EXISTS otus.offense_code;

CREATE TABLE IF NOT EXISTS otus.offense_code(
    offense_code_id INTEGER,
    name VARCHAR(240)
);

COPY otus.offense_code(
    offense_code_id,
    name
)
FROM '/home/dbadmin/docker/offense_codes.csv'
DELIMITER ','
DIRECT
ABORT ON ERROR
;