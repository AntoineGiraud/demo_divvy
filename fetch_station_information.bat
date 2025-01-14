%~d0
cd %~dp0

duckdb bikeshare.db "INSERT INTO raw.station_information select 'toulouse' as ville, ""data"".stations::json[] stations, last_updated, ttl, version FROM 'https://transport.data.gouv.fr/gbfs/toulouse/station_information.json'"
duckdb bikeshare.db "INSERT INTO raw.station_information select 'montreal' as ville, ""data"".stations::json[] stations, last_updated, ttl, null as version FROM 'https://gbfs.velobixi.com/gbfs/fr/station_information.json'"
duckdb bikeshare.db "INSERT INTO raw.station_information select 'paris' as ville, ""data"".stations::json[] stations, lastUpdatedOther last_updated, ttl, null as version FROM 'https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_information.json'"
