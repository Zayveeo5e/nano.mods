global function OnWeaponPrimaryAttack_MindHack
global function OnWeaponPrimaryAttack_MindHack_Titan
global function OnWeaponPrimaryAttack_MindHack_return

var function OnWeaponPrimaryAttack_MindHack( entity weapon, WeaponPrimaryAttackParams attackParams )
{
#if SERVER
	int ammoToSpend = weapon.GetAmmoPerShot()

	entity player = GetPlayerByIndex( 0 );

	vector eyePosition = player.EyePosition();
	vector viewVector = player.GetViewVector();

	TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

	if( traceResults.hitEnt )
	{
		printt(traceResults.hitEnt.GetClassName())
		switch ( traceResults.hitEnt.GetClassName() )
		{
			case "npc_soldier":
				thread Thylord_Mindhack( traceResults.hitEnt )
				return ammoToSpend
			break;

			case "npc_spectre":
				thread Thylord_Mindhack( traceResults.hitEnt )
				return ammoToSpend
			break;

			case "player":
				thread Thylord_Mindhack( traceResults.hitEnt )
				return ammoToSpend
			break;

			case "npc_pilot_elite":
				thread Thylord_Mindhack( traceResults.hitEnt )
				return ammoToSpend
			break;
		}
	}

	return 0
#endif
}

void function Thylord_Mindhack( entity npc )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );

	player.SetNoTarget( true )

	entity decoy = player.CreatePlayerDecoy( 0.65 )
	decoy.SetMaxHealth( 50 )
	decoy.SetHealth( 50 )
	decoy.EnableAttackableByAI( 50, 0, AI_AP_FLAG_NONE )
	decoy.SetTimeout( 5.0 )
	decoy.SetOrigin( player.GetOrigin() )
	decoy.SetAngles( player.GetAngles() )

	player.PhaseShiftBegin( 0, 0.1 )

	vector npc_pos = npc.GetOrigin()
	vector npc_ang = npc.GetAngles()

	player.SetOrigin( npc_pos )
	player.SetAngles( npc_ang )

	entity activeWeapon = npc.GetActiveWeapon()
	string weapon_name = activeWeapon.GetWeaponClassName();
	TakeAllWeapons( player )
	player.GiveWeapon( weapon_name, [] );
	player.SetActiveWeaponByName( weapon_name );
	player.GiveOffhandWeapon( "mp_ability_mindhack", OFFHAND_SPECIAL );
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE );

	player.SetHealth( player.GetMaxHealth() )

	switch ( npc.GetClassName() )
	{

		case "npc_soldier":
			//player.SetPlayerSettingsWithMods( "pilot_skin_3", [] )
			player.SetSkin( 1 )
			player.SetCamo( 31 )
			player.SetModel( npc.GetModelName() )
		break;

		case "npc_pilot_elite":
			//player.SetPlayerSettingsWithMods( "pilot_skin_3", [] )
			player.SetSkin( 0 )
			player.SetCamo( 0 )
			player.SetModel( npc.GetModelName() )
		break;

		case "npc_spectre":
			//player.SetPlayerSettingsWithMods( "pilot_skin_13", [] )
			player.SetSkin( 0 )
			player.SetCamo( 0 )
			player.SetModel( npc.GetModelName() )
		break;

		case "player":
			//player.SetPlayerSettingsWithMods( "pilot_skin_13", [] )
			player.SetSkin( 0 )
			player.SetCamo( 0 )
			player.SetModel( npc.GetModelName() )
		break;
	}

	npc.Destroy()

	wait 2.0;
	player.SetNoTarget( false )

#endif
}

var function OnWeaponPrimaryAttack_MindHack_return( entity weapon, WeaponPrimaryAttackParams attackParams )
{
#if SERVER
	int ammoToSpend = weapon.GetAmmoPerShot()

	entity player = GetPlayerByIndex( 0 );

	vector eyePosition = player.EyePosition();
	vector viewVector = player.GetViewVector();

	TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

	if( traceResults.hitEnt )
	{
		switch ( traceResults.hitEnt.GetClassName() )
		{
			case "npc_soldier":
				thread Thylord_Mindhack_return( traceResults.hitEnt )
				return ammoToSpend
			break;

			case "npc_spectre":
				thread Thylord_Mindhack_return( traceResults.hitEnt )
				return ammoToSpend
			break;

			case "npc_pilot_elite_assassin":
				thread Thylord_Mindhack_return( traceResults.hitEnt )
				return ammoToSpend
			break;

			case "npc_pilot_elite":
				thread Thylord_Mindhack_return( traceResults.hitEnt )
				return ammoToSpend
			break;
		}
	}

	return 0
#endif
}

void function Thylord_Mindhack_return( entity npc )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );

	array<StoredWeapon> StoredPlayerWeapons

	entity decoy = player.CreatePlayerDecoy( 0.65 )
	decoy.SetMaxHealth( player.GetMaxHealth() )
	decoy.SetHealth( player.GetHealth() )
	decoy.EnableAttackableByAI( 50, 0, AI_AP_FLAG_NONE )
	decoy.SetTimeout( 9999.0 )
	decoy.SetOrigin( player.GetOrigin() )
	decoy.SetAngles( player.GetAngles() )

	player.PhaseShiftBegin( 0, 0.1 )

	vector npc_pos = npc.GetOrigin()
	vector npc_ang = npc.GetAngles()
	vector player_pos = player.GetOrigin()

	int npc_team = npc.GetTeam()

	player.SetOrigin( npc_pos )
	player.SetAngles( npc_ang )

	StoredPlayerWeapons = StoreWeapons( player )

	entity activeWeapon = npc.GetActiveWeapon()
	string weapon_name = activeWeapon.GetWeaponClassName();

	activeWeapon = npc.GetActiveWeapon()
	string player_weapon = activeWeapon.GetWeaponClassName();

	TakeAllWeapons( player )

	player.GiveWeapon( weapon_name, [] );
	player.SetActiveWeaponByName( weapon_name );
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE );
	player.GiveOffhandWeapon( "mp_ability_returnhack", OFFHAND_ANTIRODEO );

	player.SetHealth( player.GetMaxHealth() )

	switch ( npc.GetClassName() )
	{

		case "npc_soldier":
			player.SetPlayerSettingsWithMods( "pilot_skin_3", [] )
			player.SetSkin( 1 )
			player.SetCamo( 31 )
			player.SetModel( npc.GetModelName() )
		break;

		case "npc_pilot_elite":
			player.SetPlayerSettingsWithMods( "pilot_skin_3", [] )
			player.SetSkin( 0 )
			player.SetCamo( 0 )
			player.SetModel( npc.GetModelName() )
		break;

		case "npc_spectre":
			player.SetPlayerSettingsWithMods( "pilot_skin_13", [] )
			player.SetSkin( 0 )
			player.SetCamo( 0 )
			player.SetModel( npc.GetModelName() )
		break;

		case "npc_pilot_elite_assassin":
			player.SetPlayerSettingsWithMods( "pilot_skin_13", [] )
			player.SetSkin( 0 )
			player.SetCamo( 0 )
			player.SetModel( npc.GetModelName() )
		break;
	}

	npc.SetOrigin( < 0, 0, 0 > )
	npc.Hide()

	SetTeam( npc, TEAM_SPECTATOR )

	wait 10.0;

	if ( !IsAlive( player ) )
	{
		decoy.SetHealth( 0 )
		return
	}

	if ( !IsAlive( decoy ) )
	{
		player.SetOrigin( player_pos )
		player.SetHealth( 0 )
		return
	}

	player.PhaseShiftBegin( 0, 0.15 )

	npc.SetOrigin( player.GetOrigin() )
	npc.SetAngles( player.GetAngles() )
	npc.Show()

	SetTeam( npc, npc_team )

	vector decoy_pos = decoy.GetOrigin()
	vector decoy_ang = decoy.GetAngles()

	player.SetOrigin( decoy_pos )
	player.SetAngles( decoy_ang )

	TakeAllWeapons( player )

	wait 0.1;

	GiveWeaponsFromStoredArray( player, StoredPlayerWeapons )

	player.SetHealth( decoy.GetHealth() )

	decoy.Destroy()

#endif
}

var function OnWeaponPrimaryAttack_MindHack_Titan( entity weapon, WeaponPrimaryAttackParams attackParams )
{
#if SERVER
	int ammoToSpend = weapon.GetAmmoPerShot()

	entity player = GetPlayerByIndex( 0 );

	if ( !player.IsTitan )
	{
		player.TakeWeaponNow( "mp_titanability_mindhack" );
		return
	}

	vector eyePosition = player.EyePosition();
	vector viewVector = player.GetViewVector();

	TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );
	if( traceResults.hitEnt )
	{

	print( traceResults.hitEnt.GetClassName() )

		switch ( traceResults.hitEnt.GetClassName() )
		{
			case "npc_titan":
				thread Thylord_Mindhack_Titan( traceResults.hitEnt )
				return ammoToSpend
			break;
		}
	}

	return 0
#endif
}

void function Thylord_Mindhack_Titan( entity npc )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );

	player.SetNoTarget( true )

	entity decoy = player.CreatePlayerDecoy( 0.65 )
	decoy.SetMaxHealth( 50 )
	decoy.SetHealth( 50 )
	decoy.EnableAttackableByAI( 50, 0, AI_AP_FLAG_NONE )
	decoy.SetTimeout( 5.0 )
	decoy.SetOrigin( player.GetOrigin() )
	decoy.SetAngles( player.GetAngles() )

	player.PhaseShiftBegin( 0, 0.2 )

	vector npc_pos = npc.GetOrigin()
	vector npc_ang = npc.GetAngles()

	player.SetOrigin( npc_pos )
	player.SetAngles( npc_ang )

	string weapon_name = npc.GetActiveWeapon().GetWeaponClassName();

	WaitFrame()

	TakeAllWeapons( player );

	WaitFrame()

	player.GiveWeapon( weapon_name, [] );

	WaitFrame()

	entity weapon = player.GetOffhandWeapon( OFFHAND_TITAN_CENTER );
	player.TakeWeaponNow( weapon.GetWeaponClassName() );

	WaitFrame()

	player.GiveOffhandWeapon( "mp_titanability_mindhack", OFFHAND_TITAN_CENTER );

	player.SetModel( npc.GetModelName() )
	player.SetSkin( npc.GetSkin() )
	player.SetCamo( npc.GetCamo() )
	player.SetDecal( npc.GetDecal() )

	player.SetHealth( player.GetMaxHealth() )

	npc.Destroy()

	wait 2.0;
	player.SetNoTarget( false )

#endif
}
