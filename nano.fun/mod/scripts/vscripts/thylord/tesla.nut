global function Thylord_Tesla_Init
global function OnWeaponPrimaryAttack_weapon_teslarcball
global function OnWeaponPrimaryAttack_titanweapon_arc_field
global function OnWeaponPrimaryAttack_titancore_foldweapon
#if SERVER
global function Tesla_RechargeWeapons
#endif 

global float teslacore_starttime

//recharge delays
global float arc_recharge_cooldown_ball
global float arc_recharge_cooldown_laser

void function Thylord_Tesla_Init()
{
#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_arc_laser, StunLaser_DamagedTarget )
	AddDamageCallbackSourceID( eDamageSourceId.melee_titan_punch_tesla, Tesla_Melee )
#endif	
}

var function OnWeaponPrimaryAttack_weapon_teslarcball( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	#if SERVER
		if ( weaponOwner.IsPlayer() )
		{
			vector angles = VectorToAngles( weaponOwner.GetViewVector() )
			vector up = AnglesToUp( angles )

			if ( weaponOwner.GetTitanSoulBeingRodeoed() != null )
				attackParams.pos = attackParams.pos + up * 20
		}
	#endif

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return weapon.GetAmmoPerShot()
	#endif

	float speed = 200.0

	vector attackPos = attackParams.pos
	vector attackDir = attackParams.dir
	
	float charge = 0.5 - weapon.GetWeaponChargeFraction() / 2
	
	float angleoffset = 0.05 + charge

	vector rightVec = AnglesToRight(VectorToAngles(attackDir))
	
	FireArcBall( weapon, attackPos, attackDir, shouldPredict, 50 )
	FireArcBall( weapon, attackPos, attackDir + rightVec * angleoffset, shouldPredict, 50 )
	FireArcBall( weapon, attackPos, attackDir + rightVec * -angleoffset, shouldPredict, 50 )
	FireArcBall( weapon, attackPos, attackDir + rightVec * angleoffset * 2, shouldPredict, 50 )
	FireArcBall( weapon, attackPos, attackDir + rightVec * -angleoffset * 2, shouldPredict, 50 )

	weapon.EmitWeaponSound_1p3p( "Weapon_ArcLauncher_Fire_1P", "Weapon_ArcLauncher_Fire_3P" )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return weapon.GetAmmoPerShot()
}

//core

var function OnWeaponPrimaryAttack_titancore_foldweapon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnAbilityStart_TitanCore( weapon )

	#if SERVER
	OnAbilityEnd_TitanCore( weapon )
	#endif

	CreateTeslaArcWave( weapon, attackParams, 0.0 )
	
	CreateTeslaArcWave( weapon, attackParams, 0.1 )
	CreateTeslaArcWave( weapon, attackParams, -0.1 )
	
	CreateTeslaArcWave( weapon, attackParams, 0.2 )
	CreateTeslaArcWave( weapon, attackParams, -0.2 )

	CreateTeslaArcWave( weapon, attackParams, 0.3 )
	CreateTeslaArcWave( weapon, attackParams, -0.3 )

	CreateTeslaArcWave( weapon, attackParams, 0.4 )
	CreateTeslaArcWave( weapon, attackParams, -0.4 )

	CreateTeslaArcWave( weapon, attackParams, 0.5 )
	CreateTeslaArcWave( weapon, attackParams, -0.5 )
	
	#if SERVER
	thread Teslacore_stoptitanregen()
	#endif

	return 1
}

var function OnWeaponPrimaryAttack_titanweapon_arc_field( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

	#if SERVER
		thread Player_ArcField( owner )
	#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function CreateTeslaArcWave( entity weapon, WeaponPrimaryAttackParams attackParams, float angleoffset )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPhaseShifted() )
		return

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return
	#endif

	vector rightVec = AnglesToRight(VectorToAngles(attackParams.dir))

	const float FUSE_TIME = 99.0
	entity projectile = weapon.FireWeaponGrenade( attackParams.pos, attackParams.dir + rightVec * angleoffset, < 0,0,0 >, FUSE_TIME, damageTypes.projectileImpact, damageTypes.explosive, shouldPredict, true, true )
	if ( IsValid( projectile ) )
	{
		entity owner = weapon.GetWeaponOwner()
		if ( owner.IsPlayer() && PlayerHasPassive( owner, ePassives.PAS_SHIFT_CORE ) )
		{
			#if SERVER
				projectile.proj.isChargedShot = true
			#endif
		}

		if ( owner.IsPlayer() )
			PlayerUsedOffhand( owner, weapon )

		#if SERVER
			thread BeginEmpWave( projectile, attackParams, angleoffset )
		#endif
	}
}

void function Tesla_Melee( entity target, var damageInfo )
{
#if SERVER
	Tesla_RechargeWeapons( 150 )
#endif
}

#if SERVER
void function BeginEmpWave( entity projectile, WeaponPrimaryAttackParams attackParams, float angleoffset )
{

	vector rightVec = AnglesToRight(VectorToAngles(attackParams.dir))

	projectile.EndSignal( "OnDestroy" )
	projectile.SetAbsOrigin( projectile.GetOrigin() )
	projectile.SetAbsAngles( projectile.GetAngles() )
	projectile.SetVelocity( Vector( 0, 0, 0 ) )
	projectile.StopPhysics()
	projectile.SetTakeDamageType( DAMAGE_NO )
	projectile.Hide()
	projectile.NotSolid()
	projectile.e.onlyDamageEntitiesOnce = true
	EmitSoundOnEntity( projectile, "arcwave_tail_3p" )
	waitthread WeaponAttackWave( projectile, 0, projectile, attackParams.pos, attackParams.dir + rightVec * angleoffset, CreateEmpWaveSegment )
	StopSoundOnEntity( projectile, "arcwave_tail_3p" )
	projectile.Destroy()
}

void function Teslacore_stoptitanregen()
{
	teslacore_starttime = Time() + 3.0
	
	wait 0.6;
	
	while( true )
	{
		SoulTitanCore_SetNextAvailableTime( GetPlayerByIndex(0).GetTitanSoul(), 0.0 )
		WaitFrame();
		
		if ( Time() > teslacore_starttime )
		{
			return
		}
	}
}

void function Tesla_RechargeWeapons( float last_maxcharge_recharge )
{
		
		//arc laser recharge
	
		bool foundarclaser = false
		entity offhandWeapon = GetPlayerByIndex(0).GetOffhandWeapon( OFFHAND_ORDNANCE )
		if ( offhandWeapon.GetWeaponClassName() == "mp_titanweapon_arc_laser" && foundarclaser == false )
		{
			foundarclaser = true
		}
		if ( foundarclaser == false )
		{
			offhandWeapon = GetPlayerByIndex(0).GetOffhandWeapon( OFFHAND_SPECIAL )
			
			if ( offhandWeapon.GetWeaponClassName() == "mp_titanweapon_arc_laser" && foundarclaser == false )
			{
				foundarclaser = true
			}
		}
		
		if ( foundarclaser == true )
		{
			if ( Time() > arc_recharge_cooldown_laser )
			{
				if ( offhandWeapon.GetWeaponPrimaryClipCount() + last_maxcharge_recharge / 2 > 100 )
				{
					offhandWeapon.SetWeaponPrimaryClipCount( 100 )
				}
				else
				{
					offhandWeapon.SetWeaponPrimaryClipCount( offhandWeapon.GetWeaponPrimaryClipCount() + last_maxcharge_recharge / 2 )
				}
				
				arc_recharge_cooldown_laser = Time() + 0.1
			}
		}
		
		//arc ball recharge
		
		bool foundarcball = false
		offhandWeapon = GetPlayerByIndex(0).GetOffhandWeapon( OFFHAND_ORDNANCE )
		if ( offhandWeapon.GetWeaponClassName() == "mp_titanability_arcball" && foundarcball == false )
		{
			foundarcball = true
		}
		if ( foundarcball == false )
		{
			offhandWeapon = GetPlayerByIndex(0).GetOffhandWeapon( OFFHAND_SPECIAL )
			
			if ( offhandWeapon.GetWeaponClassName() == "mp_titanability_arcball" && foundarcball == false )
			{
				foundarcball = true
			}
		}
		
		if ( foundarcball == true )
		{
			if ( Time() > arc_recharge_cooldown_ball )
			{
				if ( offhandWeapon.GetWeaponPrimaryClipCount() + last_maxcharge_recharge / 4 > 100 )
				{
					offhandWeapon.SetWeaponPrimaryClipCount( 100 )
				}
				else
				{
					offhandWeapon.SetWeaponPrimaryClipCount( offhandWeapon.GetWeaponPrimaryClipCount() + last_maxcharge_recharge / 4 )
				}
				
				arc_recharge_cooldown_ball = Time() + 0.1
			}
		}
}

bool function CreateEmpWaveSegment( entity projectile, int projectileCount, entity inflictor, entity movingGeo, vector pos, vector angles, int waveCount )
{
	projectile.SetOrigin( pos )

	float damageScalar
	int fxId
	if ( !projectile.proj.isChargedShot )
	{
		damageScalar = 1.0
		fxId = GetParticleSystemIndex( $"P_arcwave_exp" )
	}
	else
	{
		damageScalar = 1.5
		fxId = GetParticleSystemIndex( $"P_arcwave_exp_charged" )
	}
	StartParticleEffectInWorld( fxId, pos, angles )
	int pilotDamage = int( float( projectile.GetProjectileWeaponSettingInt( eWeaponVar.damage_near_value ) ) * damageScalar )
	int titanDamage = int( float( projectile.GetProjectileWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor ) ) * damageScalar )

	RadiusDamage(
		pos,
		projectile.GetOwner(), //attacker
		inflictor, //inflictor
		pilotDamage,
		titanDamage,
		112, // inner radius
		112, // outer radius
		SF_ENVEXPLOSION_NO_DAMAGEOWNER | SF_ENVEXPLOSION_MASK_BRUSHONLY | SF_ENVEXPLOSION_NO_NPC_SOUND_EVENT,
		0, // distanceFromAttacker
		0, // explosionForce
		DF_ELECTRICAL | DF_STOPS_TITAN_REGEN | DF_SKIP_DAMAGE_PROT,
		eDamageSourceId.mp_titanweapon_arc_wave
		)

	return true
}

void function Player_ArcField( entity owner )
{
	entity particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	particleSystem.SetValueForEffectNameKey( $"P_xo_emp_field" )
	particleSystem.SetOwner( owner )
	particleSystem.SetOrigin( owner.GetOrigin() )
	DispatchSpawn( particleSystem )
	particleSystem.SetParent( owner, "" )

	float arcfield_cooldown = Time() + 10.0
	
	while ( true )
	{	
		entity player = GetPlayerByIndex(0)
	
		array<entity> nearbyEnemies
		array<entity> ai = GetNPCArrayEx( "any", TEAM_ANY, player.GetTeam(), player.GetOrigin(), 500 )
		foreach ( guy in ai )
		{
			if ( IsAlive( guy ) )
			{
				EmitSoundOnEntity( guy, "Wpn_ArcTrap_Activate" )
				if ( guy.IsTitan() )
				{
					guy.TakeDamage( 50, player, player, { origin = player.GetOrigin(), scriptType = damageTypes.dissolve | DF_STOPS_TITAN_REGEN, damageSourceId = eDamageSourceId.deadly_fog } )
				}
				else
				{
					guy.TakeDamage( 10, player, player, { origin = player.GetOrigin(), scriptType = damageTypes.dissolve | DF_STOPS_TITAN_REGEN, damageSourceId = eDamageSourceId.deadly_fog } )
				}
			}
		}

		if ( Time() > arcfield_cooldown )
		{
			particleSystem.Destroy()
			return
		}

		
		WaitFrame();
	}
}
#endif