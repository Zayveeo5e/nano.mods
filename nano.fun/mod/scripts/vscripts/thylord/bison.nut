global function Thylord_Brawl_Core_Start
global function Thylord_Brawl_Core
global function Thylord_Bison_Init
global function OnWeaponPrimaryAttack_weapon_gauntlet

global int thylord_brawl_core_dur = 0

void function Thylord_Bison_Init()
{
#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.melee_titan_punch_fighter, StunLaser_DamagedTarget )
#endif	
}

var function OnWeaponPrimaryAttack_weapon_gauntlet( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 8, weapon.GetWeaponDamageFlags() )

	int ammoToSpend = weapon.GetAmmoPerShot()

	return ammoToSpend
}

var function Thylord_Brawl_Core_Start( entity weapon, WeaponPrimaryAttackParams attackParams )
{
#if SERVER
	thylord_brawl_core_dur = 50
	thread Thylord_Brawl_Core( weapon )
#endif
}

void function Thylord_Brawl_Core( entity weapon )
{
#if SERVER
	while (true)
	{
		entity player = GetPlayerByIndex( 0 );
		if ( player == null ) { return }
		entity melee = player.GetOffhandWeapon( OFFHAND_MELEE )
		if ( melee == null ) { return }
		string weaponName = melee.GetWeaponClassName()
		
		if ( !player.IsTitan())
		{
			ServerCommand("-melee")
			thylord_brawl_core_dur = 0
			return
		}
		
		if ( player.IsTitan() && thylord_brawl_core_dur > 0 )
		{
			ServerCommand("-melee")
			wait 0.05;
			if ( player.IsTitan())
			{
				if ( player == null ) { return }
				if ( melee == null ) { return }
				player.TakeWeaponNow( weaponName )
				player.GiveOffhandWeapon( "melee_titan_punch_fighter_core", OFFHAND_MELEE, [] )
			}
			WaitFrame()
			ServerCommand("+melee")
			wait 0.05;
			thylord_brawl_core_dur = thylord_brawl_core_dur - 1
		}
		
		if ( player.IsTitan() && thylord_brawl_core_dur == 0 )
		{
			if ( player == null ) { return }
			if ( melee == null ) { return }
			ServerCommand("-melee")
			player.TakeWeaponNow( weaponName )
			player.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, [] )
			return
		}
	}
#endif
}