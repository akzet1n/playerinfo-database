#include <sourcemod>
#include <SteamWorks>
#include <json>

#pragma semicolon 1
#pragma newdecls required

Database g_Database = null;
char g_Error[256];
char g_SteamId[32];
char g_Ip[16];
char g_Url[128];
char g_CountryCode[4];
char g_Isp[128];
char g_Query[256];

public Plugin myinfo =
{
    name = "Player Info Database",
    author = "akz",
    description = "Saves some information of each player into a database.",
    version = "1.8.0",
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
        if (!SQL_FastQuery(g_Database, "CREATE TABLE IF NOT EXISTS `data` (`steamid` varchar(32) NOT NULL, `ip` varchar(16) NOT NULL, `cc` varchar(2) NOT NULL, `isp` varchar(128) NOT NULL, `first_join` datetime NOT NULL, `last_seen` datetime NOT NULL, `times_connected` int NOT NULL DEFAULT 0, `seconds_connected` int NOT NULL DEFAULT 0, CONSTRAINT pk PRIMARY KEY (steamid, ip))"))
        {
            SQL_GetError(g_Database, g_Error, sizeof(g_Error));
            SetFailState("Failed to create table: %s", g_Error);
        }
    }
}

public void OnClientAuthorized(int client)
{
    if (!IsFakeClient(client) && g_Database != null)
    {
        GetClientIP(client, g_Ip, sizeof(g_Ip));
        GetClientAuthId(client, AuthId_Steam2, g_SteamId, sizeof(g_SteamId));
        Format(g_Url, sizeof(g_Url), "http://ip-api.com/json/%s?fields=countryCode,isp", g_Ip);
        Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, g_Url);
        SteamWorks_SetHTTPCallbacks(request, HTTPRequestCompleted);
        SteamWorks_SendHTTPRequest(request);
        CreateTimer(0.5, InsertAfterHTTPRequestCompleted);
    }
}

public int HTTPRequestCompleted(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode)
{
    if (eStatusCode != k_EHTTPStatusCode200OK)
    {
        LogError("Failed to get API answer: %d", eStatusCode);
    }
    else
    {
        int size;
        SteamWorks_GetHTTPResponseBodySize(hRequest, size);
        char[] body = new char[size];
        SteamWorks_GetHTTPResponseBodyData(hRequest, body, size);
        JSON_Object obj = view_as<JSON_Object>(json_decode(body));
        obj.GetString("countryCode", g_CountryCode, sizeof(g_CountryCode));
        obj.GetString("isp", g_Isp, sizeof(g_Isp));
        obj.Cleanup();
        delete obj;
    }
}

public Action InsertAfterHTTPRequestCompleted(Handle timer)
{
    Format(g_Query, sizeof(g_Query), "INSERT INTO data (steamid, ip, cc, isp, first_join) VALUES ('%s', '%s', '%s', '%s', NOW()) ON DUPLICATE KEY UPDATE steamid = '%s'", g_SteamId, g_Ip, g_CountryCode, g_Isp, g_SteamId);
    if (!SQL_FastQuery(g_Database, g_Query))
    {
        SQL_GetError(g_Database, g_Error, sizeof(g_Error));
        LogError("Failed to insert: %s", g_Error);
    }
}

public void OnClientDisconnect(int client)
{
    if (!IsFakeClient(client) && g_Database != null)
    {   
        Format(g_Query, sizeof(g_Query), "UPDATE data SET last_seen = NOW(), times_connected = times_connected + 1, seconds_connected = seconds_connected + %i WHERE steamid = '%s' AND ip = '%s'", RoundToNearest(GetClientTime(client)), g_SteamId, g_Ip);
        if (!SQL_FastQuery(g_Database, g_Query))
        {
            SQL_GetError(g_Database, g_Error, sizeof(g_Error));
            LogError("Failed to update: %s", g_Error);
        }
    }
}
