# SteamIDs Database
Save each player SteamID's into a MySQL database as soon as they join the server. Ideal to keep tracking of how many users a server has.

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
