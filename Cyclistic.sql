-- Created a Database named "cyclistic"

-- Creating a Table named "oct_20" for October 2020 month CSV file.
-- Creating columns as in CSV file and its data types.
-- Making "ride_id" column as Primary Key.

CREATE TABLE public.oct_20
(
    ride_id character varying,
    rideable_type character varying,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    start_station_name character varying,
    start_station_id character varying,
    end_station_name character varying,
    end_station_id character varying,
    start_lat double precision,
    start_lng double precision,
    end_lat double precision,
    end_lng double precision,
    member_casual character varying,
    PRIMARY KEY (ride_id)
)

ALTER TABLE public.oct_20
    OWNER to postgres
	
-- Imported data from CSV file to Table "oct_20".

-- Created remaining 11 Tables as above.

-- Joining all 12 months and Creating a new table "one_year"
-- While joining using UNION, I have only selected columns that is relevent for my analysis.

CREATE TABLE one_year
AS
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM oct_20
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM nov_20
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM dec_20
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM jan_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM feb_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM mar_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM apl_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM may_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM jun_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM jul_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM aug_21
UNION
SELECT ride_id, rideable_type, started_at, ended_at, member_casual FROM sep_21

-- Creating new column "ride_length".

ALTER TABLE public.one_year
ADD COLUMN ride_length integer

-- Updating column "ride_length" with difference beteween "started_at" and "ended_at" columns in minutes.

UPDATE one_year
SET ride_length = EXTRACT(EPOCH FROM (ended_at - started_at))/60

-- Sorting rows by "ride_length" column in Ascending order.

SELECT ride_length
FROM one_year
ORDER BY ride_length ASC

-- Its seen that many rows in some months contained negative values.
-- Number of rows containing Negative Values.

SELECT COUNT(*)
FROM one_year
WHERE ride_length < 0

-- Number of rows containing "ride length" less than "1" minute.

SELECT COUNT(*)
FROM one_year
WHERE ride_length < 1

-- Deleting rows containing negative values & ride length less than 1 minute.
-- Any trips that were below 60 seconds in length are potentially false starts or users trying to re-dock bike to ensure it was secure.

DELETE FROM one_year
WHERE ride_length < 1

-- Total number of rows in the table.

SELECT COUNT(*)
FROM one_year

-- Finding any NULL rows in any columns.
-- There was none.

SELECT 
SUM(CASE WHEN ride_id is NULL THEN 1 ELSE 0 END) AS ride_id_null,
SUM(CASE WHEN rideable_type is NULL THEN 1 ELSE 0 END) AS rideable_type_null,
SUM(CASE WHEN started_at is NULL THEN 1 ELSE 0 END) AS started_at_null,
SUM(CASE WHEN ended_at is NULL THEN 1 ELSE 0 END) AS ended_at_null,
SUM(CASE WHEN member_casual is NULL THEN 1 ELSE 0 END) AS member_casual_null,
SUM(CASE WHEN ride_length is NULL THEN 1 ELSE 0 END) AS ride_length_null
FROM one_year

-- Finding any duplicate rows in "ride_id" column.
-- There was none.

SELECT ride_id, COUNT(*)
FROM one_year
GROUP BY ride_id
HAVING COUNT(*) > 1

-- Creating new columns "year", "month", "day_of_week", "hour".

ALTER TABLE public.one_year
ADD COLUMN year smallint,
ADD COLUMN month character varying,
ADD COLUMN day_of_week character varying,
ADD COLUMN hour smallint

-- Updating new columns.

UPDATE one_year
SET year = EXTRACT (YEAR FROM started_at)

UPDATE one_year
SET month = TO_CHAR (started_at, 'Month')

UPDATE one_year
SET day_of_week = TO_CHAR (started_at, 'Day')

UPDATE one_year
SET hour = EXTRACT (HOUR FROM started_at)

-- Analyzing the Difference in Number of Rides Between Casual riders and Members.
-- Total Number of Rides in 1 Year.

SELECT member_casual, COUNT(*)
FROM one_year
GROUP BY member_casual

-- Number of Rides in Each Month

SELECT year, month, member_casual, COUNT(*)
FROM one_year
GROUP BY year, month, member_casual
ORDER BY year ASC, EXTRACT(MONTH FROM TO_DATE(month, 'Month')) ASC

-- Cleaning column. Deleting trailing spaces in column "day_of_week".

UPDATE one_year
SET day_of_week = TRIM(TRAILING FROM day_of_week)

-- Average Number of Rides in Each Weekday.

SELECT day_of_week, member_casual, COUNT(*)
FROM one_year
GROUP BY day_of_week, member_casual
ORDER BY
CASE day_of_week
WHEN 'Sunday' THEN 1
WHEN 'Monday' then 2
WHEN 'Tuesday' then 3
WHEN 'Wednesday' then 4
WHEN 'Thursday' then 5
WHEN 'Friday' then 6
ELSE 7
END ASC

-- Average Number of Rides in Each Hour.

SELECT hour, member_casual, COUNT(*)
FROM one_year
GROUP BY hour, member_casual
ORDER BY hour ASC

-- Analyzing Difference in Average Ride Length Between Casual riders and Members.
-- Average Ride Length in 1 Year.

SELECT member_casual, ROUND(AVG(ride_length),2)
FROM one_year
GROUP BY member_casual

-- Average Ride Length in Each Month.

SELECT year, month, member_casual, ROUND(AVG(ride_length),2)
FROM one_year
GROUP BY year, month, member_casual
ORDER BY year ASC, EXTRACT(MONTH FROM TO_DATE(month, 'Month')) ASC

-- Average Ride Length in each WeekDay.

SELECT day_of_week, member_casual, ROUND(AVG(ride_length),2)
FROM one_year
GROUP BY day_of_week, member_casual
ORDER BY
CASE day_of_week
WHEN 'Sunday' THEN 1
WHEN 'Monday' then 2
WHEN 'Tuesday' then 3
WHEN 'Wednesday' then 4
WHEN 'Thursday' then 5
WHEN 'Friday' then 6
ELSE 7
END ASC

-- Analyzing Difference in Rideable Type Usage Between Casual riders and Members.

SELECT rideable_type, member_casual, COUNT(*)
FROM one_year
GROUP BY rideable_type, member_casual