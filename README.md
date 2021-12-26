# Player Info Database
Saves the information of a player like SteamID, IP address, country and ISP into a SQL database as soon as they join the server, with two timestamps, one at the first join, and the other one at the last join. Ideal to keep track of how many unique players your server has, make stats in a certain time span, etc.

> Only tested in Counter-Strike: Global Offensive servers with a MySQL server.

# Installation
- Create a MySQL database.
- Add the database information in "steamid-ip" into your configuration file (addons/sourcemod/configs/databases.cfg).
- Upload steamids.smx into your gameserver.
- Load the plugin or restart the gameserver.

# Examples
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
SELECT * FROM data WHERE last_join > NOW() - INTERVAL 1 HOUR
```

- Get the player who first joined the server

```
SELECT * FROM data WHERE first_join = (SELECT MIN(first_join) FROM data)
```

- Get the latest player who joined the server

```
SELECT * FROM data WHERE last_join = (SELECT MAX(last_join) FROM data)
```

