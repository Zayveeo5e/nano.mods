
global function OnWeaponPrimaryAttack_weapon_double_shotgun

var function OnWeaponPrimaryAttack_weapon_double_shotgun( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 20, weapon.GetWeaponDamageFlags() )

	return 2
}
