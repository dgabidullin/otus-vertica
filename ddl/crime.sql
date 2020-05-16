DROP TABLE if EXISTS otus.crime;
CREATE TABLE otus.crime(
	incident_id VARCHAR(20),
	offense_code_id INTEGER,
	offense_code_group VARCHAR(20),
	offense_description VARCHAR(120),
	district VARCHAR(120),
	reporting_area VARCHAR(20),
	shooting VARCHAR(20),
	occured_on_date TIMESTAMP,
	year INTEGER,
	month INTEGER,
	day_of_week VARCHAR(10),
	hour INTEGER,
	ucr_part  VARCHAR(30),
	street  VARCHAR(30),
	lat FLOAT,
	long FLOAT
);
COPY otus.crime(
	incident_id,
	offense_code_id,
	offense_code_group,
	offense_description,
	district,
	reporting_area,
	shooting,
	occured_on_date,
	year,
	month,
	day_of_week,
	hour,
	ucr_part,
	street,
	lat,
	long
)
FROM '/home/dbadmin/docker/crime.csv'
DELIMITER ','
DIRECT
ABORT ON ERROR
;