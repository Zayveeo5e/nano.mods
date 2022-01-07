global function OnWeaponPrimaryAttack_ability_blink

var function OnWeaponPrimaryAttack_ability_blink( entity weapon, WeaponPrimaryAttackParams attackParams )
{
#if SERVER
	entity player = weapon.GetWeaponOwner()
	thread main_code( player )
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
#endif
}

void function main_code( entity player )
{
#if SERVER

	player.PhaseShiftBegin( 0, 0.11 )
	
	vector forwardVector = AnglesToForward( player.GetAngles() )

	forwardVector *= 10000.0;

	player.SetVelocity( < 0, 0, 0 > + forwardVector )

	wait 0.1;

	player.SetVelocity( < 0, 0, 0 > )
	vector org = player.GetOrigin()
	player.SetOrigin( org )

#endif
}