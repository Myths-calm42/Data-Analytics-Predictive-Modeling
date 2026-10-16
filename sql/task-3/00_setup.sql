DROP TABLE IF EXISTS player_profile;
DROP TABLE IF EXISTS player_day;
DROP TABLE IF EXISTS purchase;

CREATE TABLE player_profile AS
SELECT *
FROM read_csv_auto('../data/csv/player_profile.csv', header=true);

CREATE TABLE player_day AS
SELECT *
FROM read_csv_auto('../data/csv/player_day.csv', header=true);

CREATE TABLE purchase AS
SELECT *
FROM read_csv_auto('../data/csv/purchase.csv', header=true);