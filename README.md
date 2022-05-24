# Player Info Database
Saves certain information of each player that joins your server in a SQL database.

- Steam ID
- IP Address
- Country Code
- First join
- Last seen
- Number of connections
- Time played

> Only tested in a Counter-Strike: Global Offensive server with a MySQL server.

## Installation
- Create a MySQL database.
- Add the database information in "playerinfo" into your configuration file (addons/sourcemod/configs/databases.cfg).
- Upload playerinfo.smx into your server.
- Load the plugin or restart the server.

## Query Examples
- Get the number of unique Steam ID's

```
SELECT COUNT(DISTINCT steamid) FROM data;
```

- Get the number of unique IP addresses

```
SELECT COUNT(DISTINCT address) FROM data;
```

- Get the players that have joined in the last hour

```
SELECT * FROM data WHERE last_seen > NOW() - INTERVAL 1 HOUR;
```

- Get the player who first joined the server

```
SELECT * FROM data ORDER BY first_join ASC LIMIT 1;
```

- Get the latest player who left the server

```
SELECT * FROM data ORDER BY last_seen DESC LIMIT 1;
```

- Get the player who has connected the most times

```
SELECT * FROM data ORDER BY connections DESC LIMIT 1;
```

- Get the number of players per each country

```
SELECT COUNT(DISTINCT steamid), country FROM data GROUP BY country ORDER BY COUNT(DISTINCT steamid) DESC;
```

- Get the player who has been on the server the longest

```
SELECT * FROM data ORDER BY time DESC LIMIT 1;
```
