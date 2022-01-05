global function MpWeapon_Defender_Init

void function MpWeapon_Defender_Init()
{
	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_defender_ar, Defender_Ar_DamagedTarget )
	#endif
}

void function Defender_Ar_DamagedTarget( entity target, var damageInfo )
{
#if SERVER
	if ( target )
	{
		entity player = GetPlayerByIndex(0)
		entity weapon = GetPlayerByIndex(0).GetActiveWeapon()

		//weapon damage
		
		float healthcalcmax = player.GetMaxHealth().tofloat() / 2
		float healthcalccur = player.GetHealth().tofloat() / 2
		float healthcalc = healthcalcmax - healthcalccur
		
		float weapon_damage_math1 = weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value ).tofloat() + healthcalc
		
		if ( weapon_damage_math1 < 10.0 )
		{
			weapon_damage_math1 = 10.0
		}
		if ( weapon_damage_math1 > 50.0 )
		{
			weapon_damage_math1 = 50.0
		}
		
		print ( weapon_damage_math1 )
		
		DamageInfo_SetDamage( damageInfo, weapon_damage_math1 )
		
		return
	}
#endif
}