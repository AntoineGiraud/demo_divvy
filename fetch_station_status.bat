%~d0
cd %~dp0

duckdb bdd_bikeshare.db "INSERT INTO raw_gbfs.station_status select 'toulouse' as ville, ""data"".stations::json[] stations, last_updated, ttl, version FROM 'https://transport.data.gouv.fr/gbfs/toulouse/station_status.json'"
duckdb bdd_bikeshare.db "INSERT INTO raw_gbfs.station_status select 'montreal' as ville, ""data"".stations::json[] stations, last_updated, ttl, null as version FROM 'https://gbfs.velobixi.com/gbfs/fr/station_status.json'"
duckdb bdd_bikeshare.db "INSERT INTO raw_gbfs.station_status select 'paris' as ville, ""data"".stations::json[] stations, lastUpdatedOther last_updated, ttl, null as version FROM 'https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_status.json'"
duckdb bdd_bikeshare.db "INSERT INTO raw_gbfs.station_status select 'toronto' ville, data.stations::json[] stations, last_updated,	ttl, version FROM read_json('https://toronto.publicbikesystem.net/customer/gbfs/v2/en/station_status')"
