global function MpTitanAbilityHover_viper_Init
global function OnWeaponPrimaryAttack_TitanHover_viper
global function OnWeaponPrimaryAttack_homingbarrage
global function flyUp
global function PlayerPressed_up
global function PlayerReleased_up
global function StopflyUp
global function PlayerPressed_down
global function flyDown
global function OnAbilityStart_FlightCore_viper
global function OnAbilityEnd_FlightCore_viper

const LERP_IN_FLOAT = 0.7
global bool flying_rn = false
global float zvel = 0
global entity viper_homingbarrage_lasttarget

//THANKS TO SPITFIRE FOR THE POGGERS THRUSTER CODE

#if SERVER
global function FlyerHovers_viper
#endif

bool function flyUp( entity player, array<string> args )
{
	zvel = 300
	return true
}
bool function flyDown( entity player, array<string> args )
{
	zvel = -263
	return true
}

void function PlayerPressed_up( entity player )
{
#if CLIENT
	player.ClientCommand( "PlayerPressed_up" )
#endif
}

void function PlayerPressed_down( entity player )
{
#if CLIENT
	player.ClientCommand( "PlayerPressed_down" )
#endif
}

void function PlayerReleased_up( entity player )
{
#if CLIENT
	player.ClientCommand( "PlayerReleased_up" )
#endif
}

bool function StopflyUp( entity player, array<string> args )
{
	zvel = 37
	return true
}

void function MpTitanAbilityHover_viper_Init()
{
#if CLIENT
	RegisterButtonPressedCallback(KEY_SPACE,		PlayerPressed_up)
	RegisterButtonReleasedCallback(KEY_SPACE,		PlayerReleased_up)
	RegisterButtonPressedCallback(KEY_LCONTROL,		PlayerPressed_down)
	RegisterButtonReleasedCallback(KEY_LCONTROL,		PlayerReleased_up)
#endif
	PrecacheParticleSystem( $"P_xo_jet_fly_large" )
	PrecacheParticleSystem( $"P_xo_jet_fly_small" )
#if SERVER
	AddClientCommandCallback( "PlayerPressed_up", flyUp )
	AddClientCommandCallback( "PlayerReleased_up", StopflyUp )
	AddClientCommandCallback( "PlayerPressed_down", flyDown )
#endif
}

var function OnWeaponPrimaryAttack_TitanHover_viper( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity flyer = weapon.GetWeaponOwner()
	if ( !IsAlive( flyer ) )
		return
	if(flyer.IsOnGround() == false)
	{
		flying_rn = false
		return
	}
	if ( flyer.IsPlayer() )
		PlayerUsedOffhand( flyer, weapon )

	#if SERVER
		HoverSounds soundInfo
		soundInfo.liftoff_1p = "titan_flight_liftoff_1p"
		soundInfo.liftoff_3p = "titan_flight_liftoff_3p"
		soundInfo.hover_1p = "titan_flight_hover_1p"
		soundInfo.hover_3p = "titan_flight_hover_3p"
		soundInfo.descent_1p = "titan_flight_descent_1p"
		soundInfo.descent_3p = "titan_flight_descent_3p"
		soundInfo.landing_1p = "core_ability_land_1p"
		soundInfo.landing_3p = "core_ability_land_3p"
		float horizontalVelocity
		entity soul = flyer.GetTitanSoul()
		if ( IsValid( soul ) && SoulHasPassive( soul, ePassives.PAS_NORTHSTAR_FLIGHTCORE ) )
			horizontalVelocity = 1000.0
		else
			horizontalVelocity = 1000.0
		flying_rn = !flying_rn
		if(flying_rn)
		{
			thread FlyerHovers_viper( flyer, soundInfo, 3.0, horizontalVelocity )
		}
	#endif

	return 1
}

#if SERVER

void function FlyerHovers_viper( entity player, HoverSounds soundInfo, float flightTime = 3.0, float horizVel = 200.0 )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )

	thread AirborneThink( player, soundInfo )
	if ( player.IsPlayer() )
	{
		player.Server_TurnDodgeDisabledOn()
	    player.kv.airSpeed = horizVel
	    player.kv.airAcceleration = 600
	    player.kv.gravity = 0.0
	}

	CreateShake( player.GetOrigin(), 16, 150, 1.00, 400 )
	PlayFX( FLIGHT_CORE_IMPACT_FX, player.GetOrigin() )

	float startTime = Time()

	array<entity> activeFX

	player.SetGroundFrictionScale( 0 )

	OnThreadEnd(
		function() : ( activeFX, player, soundInfo )
		{
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, soundInfo.hover_1p )
				StopSoundOnEntity( player, soundInfo.hover_3p )
				player.SetGroundFrictionScale( 1 )
				if ( player.IsPlayer() )
				{
					player.Server_TurnDodgeDisabledOff()
					player.kv.airSpeed = player.GetPlayerSettingsField( "airSpeed" )
					player.kv.airAcceleration = player.GetPlayerSettingsField( "airAcceleration" )
					player.kv.gravity = player.GetPlayerSettingsField( "gravityScale" )
					if ( player.IsOnGround() )
					{
						EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.landing_1p )
						EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.landing_3p )
					}
				}
				else
				{
					if ( player.IsOnGround() )
						EmitSoundOnEntity( player, soundInfo.landing_3p )
				}
			}

			foreach ( fx in activeFX )
			{
				if ( IsValid( fx ) )
					fx.Destroy()
			}
		}
	)

	if ( player.LookupAttachment( "FX_L_BOT_THRUST" ) != 0 ) // BT doesn't have this attachment
	{
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_L_BOT_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_R_BOT_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_L_TOP_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_R_TOP_THRUST" ) ) )
	}

	EmitSoundOnEntityOnlyToPlayer( player, player,  soundInfo.liftoff_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.liftoff_3p )
	EmitSoundOnEntityOnlyToPlayer( player, player,  soundInfo.hover_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.hover_3p )

	float RISE_VEL = 450
	float movestunEffect = 1.0 - StatusEffect_Get( player, eStatusEffect.dodge_speed_slow )

	entity soul = player.GetTitanSoul()
	if ( soul == null )
		soul = player

	float fadeTime = 0.75
	StatusEffect_AddTimed( soul, eStatusEffect.dodge_speed_slow, 0.65, flightTime + fadeTime, fadeTime )

	vector startOrigin
	vector endOrigin
	float midTime = Time()
	for ( ;; )
	{
		float timePassed = Time() - startTime
		if ( !flying_rn)
			break
		if(Time() - midTime > 3.0)
		{
			midTime = Time()
			EmitSoundOnEntityOnlyToPlayer( player, player,  soundInfo.hover_1p )
			EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.hover_3p )
		}
		float height
		if ( timePassed < LERP_IN_FLOAT )
		{
		 	height = GraphCapped( timePassed, 0, LERP_IN_FLOAT, RISE_VEL * 0.5, RISE_VEL )
		}
		else
		{
			if(player.IsOnGround())
				flying_rn = false
		 	height = zvel
		}
		height *= movestunEffect

		vector vel = player.GetVelocity()
		vel.z = height
		vel = LimitVelocityHorizontal( vel, horizVel + 150 )
		player.SetVelocity( vel )
		WaitFrame()
		startOrigin = player.GetOrigin()
	}
	
	EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.descent_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.descent_3p )
	var collisionGroup = player.kv.CollisionGroup
	var solid = player.kv.solid
	while(true)
	{
		if ( player.IsOnGround())
		{
			player.kv.solid = solid
			player.Solid()
			break
		}	
		endOrigin = player.GetOrigin()
		player.NotSolid()
		player.kv.solid = 0
		vector vel = player.GetVelocity()
		vel = LimitVelocityHorizontal( vel, 100 )
		player.SetVelocity( vel )
		WaitFrame()
	}
	
	if (startOrigin.z - endOrigin.z > 100)
	{
		PlayHotdropImpactFX( player )
		EmitDifferentSoundsAtPositionForPlayerAndWorld( "Titan_1P_Warpfall_WarpToLanding_fast", "Titan_3P_Warpfall_WarpToLanding_fast", endOrigin, player, player.GetTeam())
	}

	printt( startOrigin.z - endOrigin.z)
}

void function AirborneThink( entity player, HoverSounds soundInfo )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "DisembarkingTitan" )

	if ( player.IsPlayer() )
		player.SetTitanDisembarkEnabled( false )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) && player.IsPlayer() )
				player.SetTitanDisembarkEnabled( true )
		}
	)
	wait 0.1

	while( !player.IsOnGround() )
	{
		wait 0.1
	}

	if ( player.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.landing_1p )
		EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.landing_3p )
	}
	else
	{
		EmitSoundOnEntity( player, soundInfo.landing_3p )
	}
}

vector function LimitVelocityHorizontal( vector vel, float speed )
{
	vector horzVel = <vel.x, vel.y, 0>
	if ( Length( horzVel ) <= speed )
		return vel

	horzVel = Normalize( horzVel )
	horzVel *= speed
	vel.x = horzVel.x
	vel.y = horzVel.y
	return vel
}
#endif // SERVER

var function OnWeaponPrimaryAttack_homingbarrage( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool shouldPredict = weapon.ShouldPredictProjectiles()
	
	entity target = null
	
	float speed = 2500
	
	entity weaponOwner = weapon.GetWeaponOwner()
	vector eyePosition = weaponOwner.EyePosition();
	vector viewVector = weaponOwner.GetViewVector();
	TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, weaponOwner, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );
	if( traceResults.hitEnt )
	{
		if ( traceResults.hitEnt.IsTitan() )
		{
			target = traceResults.hitEnt
			viper_homingbarrage_lasttarget = traceResults.hitEnt
		}
		else
		{
			target = viper_homingbarrage_lasttarget
		}
	}
	
	if ( target == null )

	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	SmartAmmo_SetMissileSpeedLimit( weapon, 9000 )
	SmartAmmo_SetMissileSpeed( weapon, speed )
	SmartAmmo_SetMissileHomingSpeed( weapon, speed )

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	vector upVec = AnglesToUp( VectorToAngles( attackParams.dir ) )
	
	//put another one because weird bug
	
	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	entity missile = weapon.FireWeaponMissile( attackParams.pos, attackParams.dir + upVec * 1.5, speed, damageTypes.projectileImpact | DF_IMPACT, damageTypes.explosive, false, shouldPredict )

	if ( missile )
	{
		#if SERVER
		missile.kv.lifetime = 10
		missile.SetSpeed( speed )
		missile.SetHomingSpeeds( speed, 0 )

		if ( IsValid( target ) )
			missile.SetMissileTarget( target, <0,0,0> )

			missile.SetOwner( weaponOwner )
		#endif
	}
	
	return 10
}


bool function OnAbilityStart_FlightCore_viper( entity weapon )
{
	if ( !OnAbilityCharge_TitanCore( weapon ) )
		return false

#if SERVER
	OnAbilityChargeEnd_TitanCore( weapon )
#endif

	OnAbilityStart_TitanCore( weapon )

	entity titan = weapon.GetOwner() // GetPlayerFromTitanWeapon( weapon )

#if SERVER
	if ( titan.IsPlayer() )
		Melee_Disable( titan )
	thread PROTO_FlightCore( titan, weapon.GetCoreDuration() )
#else
	if ( titan.IsPlayer() && (titan == GetLocalViewPlayer()) && IsFirstTimePredicted() )
		Rumble_Play( "rumble_titan_hovercore_activate", {} )
#endif

	return true
}

void function OnAbilityEnd_FlightCore_viper( entity weapon )
{
	entity titan = weapon.GetWeaponOwner()

	#if SERVER
	OnAbilityEnd_TitanCore( weapon )

	if ( titan != null )
	{
		if ( titan.IsPlayer() )
			Melee_Enable( titan )
		titan.Signal( "CoreEnd" )
	}
	#else
		if ( titan.IsPlayer() )
			TitanCockpit_PlayDialog( titan, "flightCoreOffline" )
	#endif
}

#if SERVER
//HACK - Should use operator functions from Joe/Steven W
void function PROTO_FlightCore( entity titan, float flightTime )
{

	EmitSoundOnEntity( GetPlayerByIndex(0), "northstar_rocket_warning" )

	table<string, bool> e
	e.shouldDeployWeapon <- false

	array<string> weaponArray = [ "mp_titancore_viper_core" ]

	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "TitanEjectionStarted" )
	titan.EndSignal( "DisembarkingTitan" )
	titan.EndSignal( "OnSyncedMelee" )

	if ( titan.IsPlayer() )
		titan.ForceStand()

	OnThreadEnd(
		function() : ( titan, e, weaponArray )
		{
			if ( IsValid( titan ) && titan.IsPlayer() )
			{
				if ( IsAlive( titan ) && titan.IsTitan() )
				{
					if ( HasWeapon( titan, "mp_titanweapon_flightcore_rockets_viper" ) )
					{
						EnableWeapons( titan, weaponArray )
						titan.TakeWeapon( "mp_titanweapon_flightcore_rockets_viper" )
					}
				}

				titan.ClearParent()
				titan.UnforceStand()
				if ( e.shouldDeployWeapon && !titan.ContextAction_IsActive() )
					DeployAndEnableWeapons( titan )

				titan.Signal( "CoreEnd" )
			}
		}
	)


	if ( titan.IsPlayer() )
	{
		const float takeoffTime = 1.0
		const float landingTime = 1.0

		e.shouldDeployWeapon = true
		HolsterAndDisableWeapons( titan )

		DisableWeapons( titan, weaponArray )
		titan.GiveWeapon( "mp_titanweapon_flightcore_rockets_viper" )
		titan.SetActiveWeaponByName( "mp_titanweapon_flightcore_rockets_viper" )

		e.shouldDeployWeapon = false
		DeployAndEnableWeapons( titan )
		
		wait flightTime

		if ( IsAlive( titan ) && titan.IsTitan() )
		{
			e.shouldDeployWeapon = true
			HolsterAndDisableWeapons( titan )

			wait landingTime
		}
	}
}
#endif
