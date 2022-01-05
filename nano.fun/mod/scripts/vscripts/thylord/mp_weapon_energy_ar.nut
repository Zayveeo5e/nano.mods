global function OnWeaponPrimaryAttack_Energy_AR

bool function CanFire_EnergyAR( entity weapon )
{
	if ( weapon.GetWeaponChargeFraction() < 1.0 )
		return false

	return true
}

var function OnWeaponPrimaryAttack_Energy_AR( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( !CanFire_EnergyAR( weapon ) )
		return 0

	return Fire_EnergyAR( weapon, attackParams )
}

int function Fire_EnergyAR( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int damageflags = weapon.GetWeaponDamageFlags()
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageflags )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}
