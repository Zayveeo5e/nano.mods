global function MartyrDeath_Init

void function MartyrDeath_Init()
{
  AddPrivateMatchModeSettingEnum( "#MODE_SETTING_CATEGORY_RIFF", "riff_payback", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "0" )
  #if SERVER
  if ( GetCurrentPlaylistVarInt( "riff_payback", 0 ) == 0 )
  {
    return
  }
  AddCallback_OnPlayerKilled( Martyrdom )
  #endif
}

void function Martyrdom( entity victim, entity attacker, var damageInfo )
{
  {
    vector velocity = Vector( 0, 0, 0 )
    Grenade_Launch( victim.GetOffhandWeapon( OFFHAND_ORDNANCE ), attacker.GetOrigin(), velocity, PROJECTILE_NOT_PREDICTED, PROJECTILE_NOT_LAG_COMPENSATED )
  }
}

entity function Grenade_Launch( entity weapon, vector attackPos, vector throwVelocity, bool isPredicted, bool isLagCompensated  )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return null
	#endif

	//TEMP FIX while Deploy anim is added to sprint
	float currentTime = Time()
	if ( weapon.w.startChargeTime == 0.0 )
		weapon.w.startChargeTime = currentTime

	entity weaponOwner = weapon.GetWeaponOwner()

	var discThrow = weapon.GetWeaponInfoFileKeyField( "grenade_disc_throw" )

	vector angularVelocity = Vector( 3600, RandomFloatRange( -1200, 1200 ), 0 )

	if ( discThrow == 1 )
		angularVelocity = Vector( 100, 100, RandomFloatRange( 1200, 2200 ) )


	float fuseTime = 1

	float baseFuseTime = 0.5

	int damageFlags = weapon.GetWeaponDamageFlags()
	entity frag = weapon.FireWeaponGrenade( attackPos, throwVelocity, angularVelocity, fuseTime, damageFlags, damageFlags, isPredicted, isLagCompensated, true )
	if ( frag == null )
		return null

	if ( discThrow == 1 ) // add wobble by pitching it slightly
	{
		Assert( !frag.IsMarkedForDeletion(), "Frag before .SetAngles() is marked for deletion." )
		frag.SetAngles( frag.GetAngles() + < RandomFloatRange( 7,11 ),0,0 > )
		//Assert( !frag.IsMarkedForDeletion(), "Frag after .SetAngles() is marked for deletion." )
		if ( frag.IsMarkedForDeletion() )
		{
			CodeWarning( "Frag after .SetAngles() was marked for deletion." )
			return null
		}
	}

	return frag
}
