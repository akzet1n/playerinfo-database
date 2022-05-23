#include <sourcemod>
#include <geoip>

#pragma semicolon 1
#pragma newdecls required

Database g_Database = null;

public Plugin myinfo =
{
    name = "Player Info Database",
    author = "akz",
    description = "Saves some information of each player into a database.",
    version = "2.0",
    url = "https://github.com/akzet1n/playerinfo-database"
};

public void OnPluginStart()
{
    Database.Connect(ConnectToDb, "playerinfo");
}

public void ConnectToDb(Database db, const char[] failure, any data)
{
    if (db == null)
    {
        SetFailState("Failed to connect to database: %s", failure);
    }
    else
    {
        LogMessage("Connection to database succesfully");
        g_Database = db;
        SQL_SetCharset(db, "UTF8");
        if (!SQL_FastQuery(g_Database, "CREATE TABLE IF NOT EXISTS `data` (`steamid` varchar(32) NOT NULL, `address` varchar(16) NOT NULL, `country` varchar(2) NOT NULL, `first_join` datetime NOT NULL, `last_seen` datetime NOT NULL, `connections` int NOT NULL DEFAULT 0, `time` int NOT NULL DEFAULT 0, CONSTRAINT pk PRIMARY KEY (steamid, address))"))
        {
            char error[256];
            SQL_GetError(g_Database, error, sizeof(error));
            SetFailState("Failed to create table: %s", error);
        }
    }
}

public void OnClientAuthorized(int client)
{
    if (!IsFakeClient(client) && g_Database != null)
    {
        char steamid[32], address[16], country[4];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        GetClientIP(client, address, sizeof(address));
        GeoipCode2(address, country);
        QuerySql(steamid, address, country, 0, 1);
    }
}

public void QuerySql(char[] steamid, char[] address, char[] country, int seconds, int option)
{
    char query[256];
    if (option)
    {
        Format(query, sizeof(query), "INSERT INTO data (steamid, address, country, first_join) VALUES ('%s', '%s', '%s', NOW()) ON DUPLICATE KEY UPDATE steamid = '%s'", steamid, address, country, steamid);
    }
    else
    {
        Format(query, sizeof(query), "UPDATE data SET last_seen = NOW(), connections = connections + 1, time = time + %i WHERE steamid = '%s' AND address = '%s'", seconds, steamid, address);   
    }
    if (!SQL_FastQuery(g_Database, query))
    {
        char error[256];
        SQL_GetError(g_Database, error, sizeof(error));
        LogError("Query failed: %s", error);
    }
}

public void OnClientDisconnect(int client)
{
    if (!IsFakeClient(client) && g_Database != null)
    {   
        char steamid[32], address[16];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        GetClientIP(client, address, sizeof(address));
        QuerySql(steamid, address, "", RoundToNearest(GetClientTime(client)), 0);
    }
}
