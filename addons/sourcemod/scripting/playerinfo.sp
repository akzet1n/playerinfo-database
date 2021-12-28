#include <sourcemod>
#include <SteamWorks>
#include <json>

#pragma semicolon 1
#pragma newdecls required

Database g_Database = null;

public Plugin myinfo =
{
    name = "Player Info Database",
    author = "akz",
    description = "Saves some information of each player into a database.",
    version = "1.8.1",
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
        char url[128], steamid[32], ip[16];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        GetClientIP(client, ip, sizeof(ip));
        Format(url, sizeof(url), "http://ip-api.com/json/%s?fields=countryCode,isp", ip);
        Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);
        SteamWorks_SetHTTPRequestContextValue(request, client);
        SteamWorks_SetHTTPCallbacks(request, HTTPRequestCompleted);
        SteamWorks_SendHTTPRequest(request);
    }
}

public int HTTPRequestCompleted(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int client)
{
    if (eStatusCode != k_EHTTPStatusCode200OK)
    {
        LogError("Failed to get API answer: %d", eStatusCode);
    }
    else
    {
        char cc[4], isp[128];
        int size;
        SteamWorks_GetHTTPResponseBodySize(hRequest, size);
        char[] body = new char[size];
        SteamWorks_GetHTTPResponseBodyData(hRequest, body, size);
        JSON_Object obj = view_as<JSON_Object>(json_decode(body));
        obj.GetString("countryCode", cc, sizeof(cc));
        obj.GetString("isp", isp, sizeof(isp));
        obj.Cleanup();
        delete obj;
        DataPack dp = new DataPack();
        dp.WriteCell(client);
        dp.WriteString(cc);
        dp.WriteString(isp);
        CreateTimer(0.5, InsertAfterHTTPRequestCompleted, dp);
    }
}

public Action InsertAfterHTTPRequestCompleted(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if (!IsFakeClient(client) && g_Database != null)
    {
        char query[256], steamid[32], ip[16], cc[4], isp[128];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        GetClientIP(client, ip, sizeof(ip));
        dp.ReadString(cc, sizeof(cc));
        dp.ReadString(isp, sizeof(isp));
        Format(query, sizeof(query), "INSERT INTO data (steamid, ip, cc, isp, first_join) VALUES ('%s', '%s', '%s', '%s', NOW()) ON DUPLICATE KEY UPDATE steamid = '%s'", steamid, ip, cc, isp, steamid);
        if (!SQL_FastQuery(g_Database, query))
        {
            char error[256];
            SQL_GetError(g_Database, error, sizeof(error));
            LogError("Failed to insert: %s", error);
        }
    }
}

public void OnClientDisconnect(int client)
{
    if (!IsFakeClient(client) && g_Database != null)
    {   
        char query[256], steamid[32], ip[16];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        GetClientIP(client, ip, sizeof(ip));
        Format(query, sizeof(query), "UPDATE data SET last_seen = NOW(), times_connected = times_connected + 1, seconds_connected = seconds_connected + %i WHERE steamid = '%s' AND ip = '%s'", RoundToNearest(GetClientTime(client)), steamid, ip);
        if (!SQL_FastQuery(g_Database, query))
        {
            char error[256];
            SQL_GetError(g_Database, error, sizeof(error));
            LogError("Failed to update: %s", error);
        }
    }
}
