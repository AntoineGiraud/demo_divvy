





-- ctrl + enter dans dbeaver --> execute les lignes qui se touchent jq'au prochain ;
set VARIABLE path_input = 'C:\Users\antoi\Documents\codes\demo_bikeshare\data\';
SELECT getvariable('path_input');



----------------------------------------------
-- load rentals
----------------------------------------------

-- create or replace table raw.raw_achats as
 SELECT * FROM read_csv(getvariable('path_input') || 'rentals/rentals_v1/Divvy_Trips_2019_Q2.csv');
 SELECT * FROM read_csv(getvariable('path_input') || 'rentals/rentals_v1/Divvy_Trips_2018_Q3.csv');
 SELECT * FROM read_csv(getvariable('path_input') || 'rentals/rentals_v1/Divvy_Trips_2019_Q4.csv');
 SELECT * FROM read_csv(getvariable('path_input') || 'rentals/Divvy_Trips_2020_Q1.csv');
 SELECT * FROM read_csv(getvariable('path_input') || 'rentals/202412-divvy-tripdata.csv');

create or replace table raw_rentals.raw_rentals_v2 as
 SELECT * FROM read_csv(getvariable('path_input') || 'rentals/rentals_v2/*.csv');
create or replace table raw_rentals.raw_rentals_v1 as
 SELECT * FROM read_csv(getvariable('path_input') || 'rentals/rentals_v1/*.csv');




----------------------------------------------
-- stg -> merge rentals
----------------------------------------------
create schema stg;

create or replace table stg.rentals as 
select
  null as rideable_type,
  -- trip_id as ride_id,
  start_time as started_at,
  end_time as ended_at,
  from_station_id as start_station_id,
  from_station_name as start_station_name,
  to_station_id as end_station_id,
  to_station_name as end_station_name,
  null as start_lat,
  null as start_lng,
  null as end_lat,
  null as end_lng,
  -- bikeid,
  tripduration,
  usertype,
  -- gender,
  -- birthyear,
from raw_rentals.raw_rentals_v1
union all
SELECT
	-- ride_id,
	rideable_type,
	started_at,
	ended_at,
	start_station_id,
	start_station_name,
	end_station_id,
	end_station_name,
	start_lat,
	start_lng,
	end_lat,
	end_lng,
	datediff('second', started_at, ended_at) tripduration,
	member_casual,
FROM bdd_bikeshare.raw_rentals.raw_rentals_v2;




----------------------------------------------
-- explo rapido
----------------------------------------------
select 
  datetrunc('month', started_at) dt_mois,
  count(1) nb_rentals
from stg.rentals
group by 1
order by 1