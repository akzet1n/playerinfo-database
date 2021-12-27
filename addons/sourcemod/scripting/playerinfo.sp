#include <sourcemod>
#include <SteamWorks>
#include <json>

#pragma semicolon 1
#pragma newdecls required

Database g_hDatabase = null;
char g_hCountryCode[4];
char g_hIsp[128];

public Plugin myinfo =
{
    name = "Player Info Database",
    author = "akz",
    description = "Saves some information of each player into a database.",
    version = "1.7.1",
    url = "https://github.com/akzet1n/playerinfo-database"
};

public void OnPluginStart()
{
    Database.Connect(SQLCallback_Connect, "playerinfo");
}

public void SQLCallback_Connect(Database db, const char[] error, any data)
{
    if (db == null)
    {
        SetFailState("Failed to connect to database: %s", error);
    }
    else
    {
        LogMessage("Connection to database succesfully");

        g_hDatabase = db;
        char query[512];
        Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS `data` (`steamid` varchar(32) NOT NULL, `ip` varchar(16) NOT NULL, `cc` varchar(4) NOT NULL, `isp` varchar(128) NOT NULL, `first_connect` datetime NOT NULL, `last_connect` datetime NOT NULL, `times_connected` int DEFAULT 0, CONSTRAINT pk PRIMARY KEY (steamid, ip))");
        
        g_hDatabase.Query(SQLCallback_CreateTable, query);
    }
}

public void SQLCallback_CreateTable(Database db, DBResultSet results, const char[] error, any data)
{
    if (db == null || results == null)
    {
        SetFailState("SQLCallback_CreateTables error: %s", error);
    }
}

public void OnClientAuthorized(int client)
{
    if (!IsFakeClient(client) && g_hDatabase != null)
    {
        char url[128], ip[16];
        GetClientIP(client, ip, sizeof(ip));
        Format(url, sizeof(url), "http://ip-api.com/json/%s?fields=countryCode,isp", ip);
        Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);
        SteamWorks_SetHTTPCallbacks(request, SteamWorks_HTTPRequestCompleted);
        SteamWorks_SendHTTPRequest(request);
        CreateTimer(0.5, InsertAfterHTTPRequest, client);
    }
}

public int SteamWorks_HTTPRequestCompleted(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode)
{
    if (eStatusCode != k_EHTTPStatusCode200OK)
    {
        LogError("SteamWorks_HTTPRequestCompleted error: %d", eStatusCode);
    }
    else
    {
        int size;
        SteamWorks_GetHTTPResponseBodySize(hRequest, size);
        char[] body = new char[size];
        SteamWorks_GetHTTPResponseBodyData(hRequest, body, size);
        JSON_Object obj = view_as<JSON_Object>(json_decode(body));
        obj.GetString("countryCode", g_hCountryCode, sizeof(g_hCountryCode));
        obj.GetString("isp", g_hIsp, sizeof(g_hIsp));
        obj.Cleanup();
        delete obj;
    }
}

public Action InsertAfterHTTPRequest(Handle timer, int client)
{
    char query[256], steamid[32], ip[16];
    GetClientIP(client, ip, sizeof(ip));
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
    Format(query, sizeof(query), "INSERT INTO data (steamid, ip, cc, isp, first_connect) VALUES ('%s', '%s', '%s', '%s', NOW()) ON DUPLICATE KEY UPDATE steamid = '%s'", steamid, ip, g_hCountryCode, g_hIsp, steamid);
    g_hDatabase.Query(SQLCallback_Insert, query);
}

public void SQLCallback_Insert(Database db, DBResultSet results, const char[] error, any data)
{
    if (db == null || results == null)
    { 
        LogError("SQLCallback_Insert error: %s", error);
    }
}

public void OnClientDisconnect(int client)
{
    if (!IsFakeClient(client) && g_hDatabase != null)
    {
        char query[256], steamid[32], ip[16];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        GetClientIP(client, ip, sizeof(ip));
        Format(query, sizeof(query), "UPDATE data SET last_connect = NOW(), times_connected = times_connected + 1 WHERE steamid = '%s' AND ip = '%s'", steamid, ip);
        g_hDatabase.Query(SQLCallback_Insert, query);
    }
}
