global function OnWeaponPrimaryAttack_ability_inertia

var function OnWeaponPrimaryAttack_ability_inertia( entity weapon, WeaponPrimaryAttackParams attackParams )
{
#if SERVER
	int ammoToSpend = weapon.GetAmmoPerShot()

	entity player = GetPlayerByIndex( 0 );
	
	vector eyePosition = player.EyePosition();
	vector viewVector = player.GetViewVector();
	
	TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );
	
	if( traceResults.hitEnt )
	{
		print ( traceResults.hitEnt.GetClassName() )
		
		switch ( traceResults.hitEnt.GetClassName() )
		{
			case "npc_soldier":
				thread thylord_inertia( weapon, traceResults.hitEnt )
				return ammoToSpend
			break;
			
			case "npc_spectre":
				thread thylord_inertia( weapon, traceResults.hitEnt )
				return ammoToSpend
			break;
			
			case "npc_pilot_elite_assassin":
				thread thylord_inertia( weapon, traceResults.hitEnt )
				return ammoToSpend
			break;
			
			case "npc_pilot_elite":
				thread thylord_inertia( weapon, traceResults.hitEnt )
				return ammoToSpend
			break;
		}
	}
	
	return 0
#endif
}

void function thylord_inertia( entity weapon, entity hitent )
{
	//PlayWeaponSound( "fire" )
	entity player = weapon.GetWeaponOwner()

	PlayerUsedOffhand( player, weapon )
			
	#if SERVER
			
	vector player_vel = player.GetVelocity()
	vector player_pos = player.GetOrigin()
	vector player_ang = player.GetAngles()

	vector hitent_vel = hitent.GetVelocity()
	vector hitent_pos = hitent.GetOrigin()
	vector hitent_ang = hitent.GetAngles()
	
	player.PhaseShiftBegin( 0, 0.1 )
	hitent.PhaseShiftBegin( 0, 0.1 )
	
	player.SetVelocity( hitent_vel )
	player.SetOrigin( hitent_pos )
	player.SetAngles( hitent_ang )

	hitent.SetVelocity( player_vel )
	hitent.SetOrigin( player_pos )
	hitent.SetAngles( player_ang )
	
	#endif
	
	#if CLIENT
		EmitSoundOnEntity( player, "Pilot_PhaseShift_Activate_1P" )
	#endif

}