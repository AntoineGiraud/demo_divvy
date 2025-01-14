

install spatial;load spatial;
-- sera utile pour créer des points/géométries :)

create schema raw_gbfs;


-- ctrl + enter dans dbeaver --> execute les lignes qui se touchent jq'au prochain ;
set VARIABLE path_input = 'C:\Users\antoi\Documents\codes\demo_bikeshare\data\';
SELECT getvariable('path_input');


----------------------------------------------
-- BikeShares around the world
----------------------------------------------

create table raw_gbfs.earth_systems as
from 'https://raw.githubusercontent.com/MobilityData/gbfs/refs/heads/master/systems.csv'

select *, lower(location) location_lower
from raw_gbfs.earth_systems
where location_lower like '%york%'
  or location_lower like '%paris%'
  or location_lower like '%toulouse%'
  or location_lower like '%toronto%'
  or location_lower like '%washington%'


----------------------------------------------------
-- explo rapido de qq station_information.json
----------------------------------------------------

-- à quoi ressemble telquel le json ??
 select *
 from read_json('https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_information.json')

-- et si je le formate un peu pour Montréal ?
-- create or replace table raw_gbfs.station_information as 
 select
	'montreal' ville,
	--data::json "data", --> on va plutôt directement extraire les infos des stations
	data.stations::json[] stations,
	last_updated,
	ttl,
	null as version
FROM 'https://gbfs.velobixi.com/gbfs/fr/station_information.json';

-- et si je le formate un peu pour Paris ?
-- insert into raw_gbfs.station_information
 select
	'paris' ville,
	data.stations::json[] stations,
	lastUpdatedOther as last_updated,
	ttl,
	null as version
FROM 'https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_information.json';

----------------------------------------------------
-- explo de ce qu'on pourrait faire de ces données station information
----------------------------------------------------

-- et si je le formate un peu pour Montréal ?
-- create or replace view stg.gbfs_station_information as
with stations as (
	SELECT
		ville,
		unnest(stations) as station,
		to_timestamp(last_updated)::TIMESTAMPTZ AT TIME ZONE (case when ville='montreal' then 'America/Montreal' else 'Europe/Paris' end) last_updated,
		ttl,
		version
	FROM raw_gbfs.station_information
	-- where ville='toulouse'
)
select
	ville,
	station->>'station_id' station_id,
	station->>'name' "name",
	(station->'capacity')::int capacity,
	ST_point((station->'lon')::numeric, (station->'lat')::numeric) geom_point,
	station raw,
	last_updated,
	ttl,
	version
from stations
;


----------------------------------------------------
-- explo rapido de qq station_status.json
----------------------------------------------------

-- à quoi ressemble telquel le json ??
 from read_json('https://gbfs.velobixi.com/gbfs/fr/station_status.json')

-- et si je le formate un peu pour Montréal ?
-- create or replace table raw_gbfs.station_status as 
 select
	'montreal' ville,
	--data::json "data", --> on va plutôt directement extraire les infos des stations
	data.stations::json[] stations,
	last_updated,
	ttl,
	null as version
FROM 'https://gbfs.velobixi.com/gbfs/fr/station_status.json';

-- et si je le formate un peu pour Paris ?
-- insert into raw_gbfs.station_status
 select
	'paris' ville,
	data.stations::json[] stations,
	lastUpdatedOther as last_updated,
	ttl,
	null as version
FROM 'https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_status.json';


----------------------------------------------------
-- explo de ce qu'on pourrait faire de ces données station information
----------------------------------------------------

-- et si je le formate un peu pour Montréal ?
-- create or replace view stg.gbfs_station_status as
with stations as (
	SELECT
		ville,
		unnest(stations) as station,
		to_timestamp(last_updated)::TIMESTAMPTZ AT TIME ZONE (case when ville='montreal' then 'America/Montreal' else 'Europe/Paris' end) last_updated,
		ttl,
		version
	FROM raw_gbfs.station_status
	-- where ville='toulouse'
)
select
	ville,
	station->>'station_id' station_id,
	station->>'name' "name",
	(station->'num_bikes_available')::int num_bikes_available,
	(station->'capacity')::int capacity,
	ST_point((station->'lon')::numeric, (station->'lat')::numeric) geom_point,
	station raw,
	last_updated,
	ttl,
	version
from stations
;



--========================================================
-- LET'S GO VERS l'ingestion plein de fois dans la journée
--========================================================

----------------------------------------------------
-- insert into station_status
----------------------------------------------------
insert into raw_gbfs.station_status 
select 'montreal' ville, data.stations::json[] stations, last_updated, ttl, null as version
FROM 'https://gbfs.velobixi.com/gbfs/fr/station_status.json';

insert into raw_gbfs.station_status
select 'paris' ville, data.stations::json[] stations, lastUpdatedOther as last_updated,	ttl, null as version
FROM 'https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_status.json';

-- est ce que j'ai bien ingéré ??
select *
from stg.gbfs_station_status
order by ville, station_id

----------------------------------------------------
-- insert into station_information
----------------------------------------------------
insert into raw_gbfs.station_information 
select 'montreal' ville, data.stations::json[] stations, last_updated, ttl, null as version
FROM 'https://gbfs.velobixi.com/gbfs/fr/station_information.json';

insert into raw_gbfs.station_information
select 'paris' ville, data.stations::json[] stations, lastUpdatedOther as last_updated,	ttl, null as version
FROM 'https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_information.json';

-- est ce que j'ai bien ingéré ??
select *
from stg.gbfs_station_information
order by ville, station_id

