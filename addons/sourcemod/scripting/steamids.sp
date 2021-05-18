#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

Database g_hDatabase = null;

public Plugin myinfo =
{
    name = "SteamIDs Database",
    author = "akz",
    description = "Saves each player SteamID's into a MySQL database.",
    version = "1.0",
    url = "https://github.com/akzet1n/steamids-database"
};

public void OnPluginStart()
{
    Database.Connect(ConnectSQL, "steamids");
}

public void ConnectSQL(Database db, const char[] error, any data)
{
    if(db == null)
    {
        LogError("Failed to connect to MySQL server: %s", error);
    }
    else
    {
        g_hDatabase = db;
    }
}

public void OnClientPutInServer(int client) 
{ 
    if(!IsFakeClient(client) && g_hDatabase != null) 
    {
        char query[128], steamid[32]; 
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid)); 
        Format(query, sizeof(query), "SELECT * FROM data WHERE steamid = '%s'", steamid); 
        g_hDatabase.Query(QuerySQL, query, GetClientUserId(client)); 
    } 
} 

public void QuerySQL(Database db, DBResultSet results, const char[] error, any data)
{
    if(db == null || results == null)
    { 
        LogError("QuerySQL has returned the following error: %s", error); 
        return;
    }

    char query[128], steamid[32];
    int client = GetClientOfUserId(data);
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

    if(!SQL_FetchRow(results))
    {
        Format(query, sizeof(query), "INSERT INTO data(steamid, last_visit) VALUES ('%s', NOW())", steamid);
    }
    else
    {
        Format(query, sizeof(query), "REPLACE INTO data(steamid, last_visit) VALUES ('%s', NOW())", steamid);
    }
    g_hDatabase.Query(InsertSQL, query);
}

public void InsertSQL(Database db, DBResultSet results, const char[] error, any data)
{
    if(db == null || results == null) 
    { 
        LogError("InsertSQL has returned the following error: %s", error); 
        return;
    }
}
