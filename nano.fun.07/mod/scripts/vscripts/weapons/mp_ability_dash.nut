global function OnWeaponPrimaryAttack_Dash

var function OnWeaponPrimaryAttack_Dash( entity weapon, WeaponPrimaryAttackParams attackParams)
{
  #if SERVER
  entity player = weapon.GetWeaponOwner();
  FlingEnt( player )
  #endif
}
