/************************************************************************
  [L4D] Auto-Scrambleteams - A plugin for Left 4 Dead 2

  DESCRIPTION: 
  
  This plugin mixes the players in the teams, and is always executed 
  on the first campaign map.
  
  CHANGELOG:

  2019-01-12 (v1.0.0)
    - Initial release.

  2019-01-12 (v0.1.0)
    - Initial version.

 ************************************************************************/

#include <sourcemod>
#include <sdkhooks>

/**
 * Compiler requires semicolons and the new syntax.
 */
#pragma semicolon  1
#pragma newdecls   required

/**
 * Semantic versioning <https://semver.org/>
 */
#define PLUGIN_VERSION            "0.1.0" 		

public Plugin myinfo = {
	name        = "[L4D] Auto-Scrambleteams",
	description = "This plugin mixes the players in the teams",
	author      = "samuelviveiros a.k.a Dartz8901",
	version     = PLUGIN_VERSION,
	url         = "https://github.com/samuelviveiros/l4d2_auto_scrambleteams"
};

Handle g_hScrambleDelay = null;
bool g_bPlayerAlreadyEnteredStartArea = false;

public void OnPluginStart()
{
    CreateConVar(
        "l4d2_auto_scrambleteams_version", 
        PLUGIN_VERSION, 
        "[L4D2] Auto-Scrambleteams plugin version", 
        FCVAR_REPLICATED | FCVAR_NOTIFY
    );
    g_hScrambleDelay = CreateConVar(
        "l4d2_auto_scrambleteams_delay",
        "15.0", 
        "How long to mix the teams after the gameplay begins", 
        FCVAR_NOTIFY,
        true, 1.0
    );
    AutoExecConfig(true, "l4d2_auto_scrambleteams");

    HookEvent("player_entered_start_area", Event_PlayerEnteredStartArea);
}

//
// Works only in the first campaign map
//
public Action Event_PlayerEnteredStartArea(Event event, const char[] name, bool dontBroadcast)
{
    if ( StrEqual(name, "player_entered_start_area") )
    {
        if ( g_bPlayerAlreadyEnteredStartArea )
        {
            return Plugin_Continue;
        }
        g_bPlayerAlreadyEnteredStartArea = true;
        CreateTimer(GetConVarFloat(g_hScrambleDelay), Timer_ExecCmd);
    }
    return Plugin_Continue;
}

public Action Timer_ExecCmd(Handle timer, any data)
{
    if ( !CommandExists("sm_scrambleteams") )
    {
        LogError("Command sm_scrambleteams not found.");
        return Plugin_Stop;
    }
    ServerCommand("sm_scrambleteams");
    return Plugin_Stop;
}

public void OnMapStart()
{
    g_bPlayerAlreadyEnteredStartArea = false;
}
