# Player Info Database
Saves the information of each player that joins your server and sends it into a database. Ideal to keep track of the users that are playing around your server, get stats with the interval you want, daily, weekly, etc. At the moment, the plugin is gathering the following values: **Steam ID**, **IP Address**, **Country Code**, **ISP**, **First join date**, **Last seen date**, **Number of Connections** & **Time Played**.

> Only tested in a Counter-Strike: Global Offensive server with a MySQL server.

## Installation
- Create a MySQL database.
- Add the database information in "playerinfo" into your configuration file (addons/sourcemod/configs/databases.cfg).
- Upload playerinfo.smx into your gameserver.
- Load the plugin or restart the gameserver.

## Examples
- Get the number of unique users

```
SELECT COUNT(DISTINCT steamid) FROM data
```

- Get the number of unique IP addresses

```
SELECT COUNT(DISTINCT ip) FROM data
```

- Get the players that have joined in the last hour

```
SELECT * FROM data WHERE last_seen > NOW() - INTERVAL 1 HOUR
```

- Get the player who first joined the server

```
SELECT * FROM data WHERE first_join = (SELECT MIN(first_join) FROM data)
```

- Get the latest player who left the server

```
SELECT * FROM data WHERE last_seen = (SELECT MAX(last_seen) FROM data)
```

- Get the player who has connected the most times

```
SELECT * FROM data WHERE times_connected = (SELECT MAX(times_connected) FROM data)
```

- Get the number of players per each country

```
SELECT cc, COUNT(*) AS players FROM data GROUP BY cc ORDER BY players DESC
```

- Get the number of players per each ISP

```
SELECT isp, COUNT(*) AS players FROM data GROUP BY isp ORDER BY players DESC
```

- Get the country with the most players

```
SELECT cc, COUNT(*) AS players FROM data GROUP BY cc ORDER BY players DESC LIMIT 1
```

- Get the ISP with the most players

```
SELECT isp, COUNT(*) AS players FROM data GROUP BY isp ORDER BY players DESC LIMIT 1
```

- Get the country with the least players

```
SELECT cc, COUNT(*) AS players FROM data GROUP BY cc ORDER BY players ASC LIMIT 1
```

- Get the ISP with the least players

```
SELECT isp, COUNT(*) AS players FROM data GROUP BY isp ORDER BY players ASC LIMIT 1
```

- Get the player who has been on the server the longest

```
SELECT * FROM data WHERE seconds_connected = (SELECT MAX(seconds_connected) FROM data)
```



