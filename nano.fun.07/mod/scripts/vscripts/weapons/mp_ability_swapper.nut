global function OnWeaponPrimaryAttack_Swap

var function OnWeaponPrimaryAttack_Swap( entity weapon, WeaponPrimaryAttackParams attackParams )
{
  #if SERVER
  entity player = weapon.GetWeaponOwner();
  vector eyePosition = player.EyePosition();
	vector viewVector = player.GetViewVector();
  TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 100000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

  if (traceResults.hitEnt)
  {
    string entHit = traceResults.hitEnt.GetClassName()
    if( entHit != "worldspawn" )
    {
      printt(traceResults.hitEnt.GetClassName())
      thread Nano_Swapper( traceResults.hitEnt, player )
    }
  }
  return 0
#endif
}
void function Nano_Swapper( entity victim, entity player )
{
  #if SERVER
  //entity player = weapon.GetWeaponOwner();
  player.PhaseShiftBegin( 0, 0.1 )
  player.PhaseShiftBegin( 0, 0.1 )

  vector victim_pos = victim.GetOrigin()
  vector victim_ang = victim.GetAngles()
  vector player_pos = player.GetOrigin()
  vector player_ang = player.GetAngles()

  player.SetOrigin( victim_pos )
  player.SetAngles( victim_ang )
  victim.SetOrigin( player_pos )
  victim.SetAngles( player_ang )
  #endif
}
