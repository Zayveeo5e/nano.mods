global function PilotModCommand
global function ApplyPilotMods

void function PilotModCommand
{
  #if SERVER
  AddClientCommandCallback("PilotMod", ApplyPilotMod);
  #endif
}

void function ApplyPilotMods( entity player, string pmodID array<string> args )
{
  switch (args[0]) {
    pmodID = args[0]
  }
  printt("Applying Pilot Mod: ", pmodID)
  player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), [ pmodID ] )
}
