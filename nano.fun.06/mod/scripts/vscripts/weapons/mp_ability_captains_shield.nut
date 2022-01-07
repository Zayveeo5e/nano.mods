global function OnWeaponPrimaryAttack_CShield
const CSHIELD_DURATION = 15.0

void function MpAbilityCShield_Init()
{
  PrecacheWeapon("mp_ability_cshield")
}

var function OnWeaponPrimaryAttack_CShield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
  #if SERVER
  entity player = weapon.GetWeaponOwner();
  thread ActivatePersonalShield(player)
  //wait 15
  #endif
}
