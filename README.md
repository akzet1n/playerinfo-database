# Player Info Database
Saves the information of each player that joins your server and sends it into a database. Ideal to keep track of the users that are playing around your server, get stats with the interval you want, daily, weekly, etc. At the moment, the plugin is gathering the following values: **Steam ID**, **IP Address**, **Country Code**, **ISP**, **First join date**, **Last seen date** and **Number of Connections**.

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
SELECT * FROM data WHERE last_connect > NOW() - INTERVAL 1 HOUR
```

- Get the player who first joined the server

```
SELECT * FROM data WHERE first_connect = (SELECT MIN(first_connect) FROM data)
```

- Get the latest player who joined the server

```
SELECT * FROM data WHERE last_connect = (SELECT MAX(last_connect) FROM data)
```

- Get the player who has connected the most times

```
SELECT * FROM data WHERE times_connected = (SELECT MAX(times_connected) FROM data)
```

