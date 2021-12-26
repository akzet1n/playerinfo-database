#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

Database g_hDatabase = null;

public Plugin myinfo =
{
    name = "Player Info Database",
    author = "akz",
    description = "Saves the information of each player into a database.",
    version = "1.7",
    url = "https://github.com/akzet1n/playerinfo-database"
};

public void OnPluginStart()
{
    Database.Connect(SQLCallback_Connect, "playerinfo");
}
    
public void SQLCallback_Connect(Database db, const char[] error, any data)
{
    if(db == null)
    {
        SetFailState("Failed to connect to database: %s", error);
    }
    else
    {
        LogMessage("Conecction to database succesfully.");

        g_hDatabase = db;
        char driver[64], query[256];
        DBDriver tmp = g_hDatabase.Driver;
        tmp.GetIdentifier(driver, sizeof(driver));

        if(StrEqual(driver, "sqlite"))
        {
            Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `data` (`steamid` varchar(32) NOT NULL, `ip` varchar(16) NOT NULL, `country` varchar(2) NOT NULL, `isp` varchar(128) NOT NULL, `first_join` datetime NOT NULL, `last_join` datetime NOT NULL)");

        }
        else
        {   
            Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `data` (`steamid` varchar(32) NOT NULL, `ip` varchar(16) NOT NULL, `country` varchar(2) NOT NULL, `isp` varchar(128) NOT NULL, `first_join` datetime NOT NULL, `last_join` datetime NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
        }

        g_hDatabase.Query(SQLCallback_CreateTable, query);
    }
}

public void SQLCallback_CreateTable(Database db, DBResultSet results, const char[] error, any data)
{
    if(db == null || results == null)
    {
        SetFailState("SQLCallback_CreateTables error: %s", error);
    }
}

public void OnClientAuthorized(int client)
{
    if(!IsFakeClient(client) && g_hDatabase != null)
    {
        char query[128], steamid[32], address[16];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        GetClientIP(client, address, sizeof(address));
        Format(query, sizeof(query), "SELECT * FROM data WHERE (steamid = '%s' AND ip = '%s')", steamid, address);
        g_hDatabase.Query(SQLCallback_Query, query, GetClientUserId(client));
    }
}

public void SQLCallback_Query(Database db, DBResultSet results, const char[] error, any data)
{
    if(db == null || results == null)
    { 
        LogError("SQLCallback_Query error: %s", error);
        return;
    }

    char query[256], steamid[32], address[16];
    int client = GetClientOfUserId(data);
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
    GetClientIP(client, address, sizeof(address));

    if(!SQL_FetchRow(results))
    {
        Format(query, sizeof(query), "INSERT INTO data(steamid, ip, first_join, last_join) VALUES ('%s', '%s', NOW(), NOW())", steamid, address);
    }
    else
    {
        Format(query, sizeof(query), "UPDATE data SET last_join = NOW() WHERE (steamid = '%s' AND ip = '%s')", steamid, address);
    }

    g_hDatabase.Query(SQLCallback_Insert, query);
}

public void SQLCallback_Insert(Database db, DBResultSet results, const char[] error, any data)
{
    if(db == null || results == null)
    { 
        LogError("SQLCallback_Insert error: %s", error);
        return;
    }
}
