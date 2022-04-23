# Player Info Database
Saves the information of each player that joins your server and sends it into a database. Ideal to keep track of the users that are playing around your server, get stats with the interval you want, daily, weekly, etc. At the moment, the plugin is gathering the following values: **Steam ID**, **IP Address**, **Country Code**, **ISP**, **First join date**, **Last seen date**, **Number of Connections** & **Time Played**.

> Only tested in a Counter-Strike: Global Offensive server with a MySQL server.

## Installation
- Create a MySQL database.
- Add the database information in "playerinfo" into your configuration file (addons/sourcemod/configs/databases.cfg).
- Upload playerinfo.smx into your server.
- Load the plugin or restart the server.

## Examples
- Get the number of unique Steam ID's

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
SELECT * FROM data ORDER BY first_join ASC LIMIT 1
```

- Get the latest player who left the server

```
SELECT * FROM data ORDER BY last_seen DESC LIMIT 1
```

- Get the player who has connected the most times

```
SELECT * FROM data ORDER BY times_connected DESC LIMIT 1
```

- Get the number of players per each country

```
SELECT COUNT(DISTINCT steamid), cc FROM data GROUP BY cc ORDER BY COUNT(DISTINCT steamid) DESC
```

- Get the number of players per each ISP

```
SELECT COUNT(DISTINCT steamid), isp FROM data GROUP BY isp ORDER BY COUNT(DISTINCT steamid) DESC
```

- Get the player who has been on the server the longest

```
SELECT * FROM data ORDER BY seconds_connected DESC LIMIT 1
```

## IP-API.com
By default, the plugin is using [IP-API.com](https://ip-api.com) in a free version that can take up to 45 requests in a single minute. If the plugin requests more than 45 times in a single minute, the API will begin to throttle down all the requests until the minute has passed. If you have a high number of concurrent players, that can exceed that rate limit, you can pay for a premium version or make your own API.
