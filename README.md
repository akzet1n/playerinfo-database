# SteamIDs Database
Save each player SteamID's into a MySQL database as soon as they join the server. Ideal to keep tracking of how many unique users a gameserver has in a certain time span.
Only tested in Counter-Strike: Global Offensive servers with a MySQL server.

# Usage
- Create a MySQL database.
- Import the data.sql file into your database.
- Add the database information into your configuration file (addons/sourcemod/configs/databases.cfg).
```
"steamids"
{
    "driver"      "mysql"
    "host"        ""
    "database"    ""
    "user"        ""
    "pass"        ""
    "port"        ""
}
```
- Upload steamids.smx into your gameserver.
