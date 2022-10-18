use Bixi;

/* Questions 1 */

-- 1. The total number of trips for year of 2016. Answer: 3,917,401

SELECT
	COUNT(ID) AS total_number_of_trips
FROM trips
WHERE YEAR(start_date) = 2016; -- Duration: 1.801 sec

-- 2. The total number of trips for year of 2017. Answer: 4,666,765

SELECT
	COUNT(ID) AS total_number_of_trips
FROM trips
WHERE YEAR(start_date) = 2017; -- Duration: 1.423 sec

-- 3. The total number of trips for the year of 2016 broken-down by month

SELECT
	MONTH(start_date) AS Month,
	COUNT(ID) AS total_number_of_trips
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY Month; -- Duration: 2.119 sec

-- 4. The total number of trips for the year of 2017 broken-down by month

SELECT
	MONTH(start_date) AS Month,
	COUNT(ID) AS total_number_of_trips
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY Month; -- Duration: 2.663 sec

-- 5. The average number of trips a day for each year-month combination in the dataset

SELECT
	YEAR(start_date) AS Year,
	MONTH(start_date) AS Month,
    CASE 
		WHEN MONTH(start_date) = 4 OR MONTH(start_date) = 6 OR MONTH(start_date) = 9 OR MONTH(start_date) = 11 THEN COUNT(ID)/30
		ELSE COUNT(ID)/31 END AS Average_trips
FROM trips
GROUP BY Year,Month; - -- Duration:3.350  sec

-- SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- 6. Save your query results from the previous question 1.5 by creating a table called working_table1

CREATE TABLE working_table1 AS
SELECT
	YEAR(start_date) AS Year,
	MONTH(start_date) AS Month,
    CASE 
		WHEN MONTH(start_date) = 4 OR MONTH(start_date) = 6 OR MONTH(start_date) = 9 OR MONTH(start_date) = 11 THEN COUNT(ID)/30
		ELSE COUNT(ID)/31 END AS Average_trips
FROM trips
GROUP BY Year,Month; -- Duration: 6.882 sec

/* Question 2 Unsurprisingly, the number of trips varies greatly throughout the year. 
How about membership status? Should we expect member and non-member to behave differently?
 To start investigating that, calculate:*/

-- 1. The total number of trips in the year 2017 broken-down by membership status (member/non-member).

SELECT
	is_member AS member_status,
	COUNT(ID) AS total_number_of_trips
FROM trips
WHERE YEAR(start_date) = 2017
GROUP by member_status; -- Duration: 2.107 sec

-- 2. The fraction of total trips that were done by members for the year of 2017 broken-down by month.

SELECT
	MONTH(start_date) AS Month,
	COUNT(ID) /4666765 AS fraction_of_total_trips
FROM trips
WHERE YEAR(start_date) = 2017 AND is_member = 1
GROUP by Month;

/*Question 3: Use the above queries to answer the questions below

 1. Which time of the year the demand for Bixi bikes is at its peak?

Answer: July and August


-- 2. If you were to offer non-members a special promotion in an attempt to convert them to members, 
when would you do it? 

Answer: offer promotion in April, May, October and November. */

/* Question 4: It is clear now that average temperature and membership status are intertwined and influence greatly 
how people use Bixi bikes. Let’s try to bring this knowledge with us and learn something about 
station popularity. */

-- 1. What are the names of the 5 most popular starting stations? Solve this problem without
-- using a subquery

SELECT
	name,
	COUNT(id) AS station_visit_count
FROM trips LEFT JOIN stations
	ON trips.start_station_code = stations.code
GROUP by name
ORDER BY station_visit_count DESC  
LIMIT 5; -- Duration: 41.202 sec

-- 2. Solve the same question as Q4.1, but now use a subquery. 
-- Is there a difference in query run time between 4.1 and 4.2?


SELECT
	name,
	station_visit_count
FROM
(SELECT
	start_station_code,
    COUNT(id) AS station_visit_count
FROM trips
GROUP BY start_station_code
ORDER BY station_visit_count DESC
LIMIT 5
) AS sub_query LEFT JOIN stations
ON sub_query.start_station_code = stations.code;  -- duration: 3.896 sec, approximately 10% duration time of previous query


/*Questions 5 */
-- How is the number of starts and ends distributed for the station 
-- Mackay / de Maisonneuve throughout the day?

-- Starting trips distribution:
SELECT 
CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
       END AS "time_of_day",
COUNT(id) AS station_visit_count
FROM trips LEFT JOIN stations
	ON trips.start_station_code = stations.code
WHERE name = 'Mackay / de Maisonneuve'
GROUP BY time_of_day; -- duration: 0.324 sec

-- Ending trips distribution:
SELECT 
CASE
       WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
       END AS "time_of_day",
COUNT(id) AS station_visit_count
FROM trips LEFT JOIN stations
	ON trips.end_station_code = stations.code
WHERE name = 'Mackay / de Maisonneuve'
GROUP BY time_of_day; -- duration: 0.408 sec

/* Question 6 List all stations for which at least 10% of trips are round trips.
 Round trips are those that start and end in the same station. 
 This time we will only consider stations with at least 500 starting trips. */
 
-- 1. First, write a query that counts the number of starting trips per station.

SELECT
stations.name,
stations.code,
starting_trip_count
FROM
(SELECT
	start_station_code,
    COUNT(id) AS starting_trip_count
FROM trips
GROUP BY start_station_code) AS sub_query LEFT JOIN stations
ON sub_query.start_station_code = stations.code; -- Duration: 0.0003 sec



-- 2. Second, write a query that counts, for each station, the number of round trips.

SET @@global.net_read_timeout=360;

SELECT
station_id,
COUNT(id) AS round_trip_count
FROM
(SELECT
	start_station_code AS station_id,
	id
FROM trips
WHERE start_station_code = end_station_code) AS sub_query
GROUP BY 1; -- Fetch Time: 400.269 sec


-- 3. Combine the above queries and calculate the fraction of round trips to 
-- the total number of starting trips for each station.

CREATE TABLE Station_trip_count AS 
SELECT
station_name,
starting_trip_count,
round_trip_count,
round_trip_count/starting_trip_count AS Perent_round_trip
FROM
(SELECT
stations.name AS station_name,
stations.code AS station_code,
starting_trip_count
FROM
(SELECT
	start_station_code,
    COUNT(id) AS starting_trip_count
FROM trips
GROUP BY start_station_code) AS sub_query LEFT JOIN stations
ON sub_query.start_station_code = stations.code) AS station_visit_count_table
LEFT JOIN
(SELECT
station_id,
COUNT(id) AS round_trip_count
FROM
(SELECT
	start_station_code AS station_id,
	id
FROM trips
WHERE start_station_code = end_station_code) AS sub_query
GROUP BY 1) AS round_trip_count_table 
ON station_visit_count_table.station_code = round_trip_count_table.station_id;
-- Duration time: 455.576 sec

-- 4. Filter down to stations with at least 500 trips originating from them 
-- and having at least 10% of their trips as round trips.

SELECT * FROM Station_trip_count
WHERE starting_trip_count >= 500 AND Perent_round_trip >= 0.1;

select * from Station_trip_count;

-- 5.Where would you expect to find stations with a high fraction of round trips?
 -- in residential area or near public transportation that allow bikers to transfer




