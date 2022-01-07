global function OnWeaponPrimaryAttack_ability_dash

const PHASE_DASH_SPEED = 700

var function OnWeaponPrimaryAttack_ability_dash( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	//PlayWeaponSound( "fire" )
	entity player = weapon.GetWeaponOwner()

	if ( IsAlive( player ) )
	{

		if ( player.IsPlayer() )
		{
			PlayerUsedOffhand( player, weapon )
			
				#if SERVER
				
					EmitSoundOnEntityExceptToPlayer( player, player, "Pilot_PhaseShift_Activate_1P" )
					thread Dash( weapon, player )
					
				#elseif CLIENT
				
			float xAxis = InputGetAxis( ANALOG_LEFT_X )
			float yAxis = InputGetAxis( ANALOG_LEFT_Y ) * -1
			
			vector angles = player.EyeAngles()
			vector directionForward = GetDirectionFromInput( angles, xAxis, yAxis )
			
			EmitSoundOnEntity( player, "Pilot_PhaseShift_Activate_1P" )
			
			#endif
		}

	}
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER

void function Dash( entity weapon, entity player )
{
	float moveSpeed
	moveSpeed = PHASE_DASH_SPEED
	SetPlayerVelocityFromInput( player, moveSpeed, <0,0,200> )
}

#endif

vector function GetDirectionFromInput( vector playerAngles, float xAxis, float yAxis )
{
	playerAngles.x = 0
	playerAngles.z = 0
	vector forward = AnglesToForward( playerAngles )
	vector right = AnglesToRight( playerAngles )

	vector directionVec = Vector(0,0,0)
	directionVec += right * xAxis
	directionVec += forward * yAxis

	vector directionAngles = VectorToAngles( directionVec )
	vector directionForward = AnglesToForward( directionAngles )

	return directionForward
}