global function OnWeaponPrimaryAttack_ability_duo

var function OnWeaponPrimaryAttack_ability_duo( entity weapon, WeaponPrimaryAttackParams attackParams )
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
	entity npc = CreateNPCFromAISettings( "npc_soldier", player.GetTeam(), player.GetOrigin(), player.GetAngles() )
	DispatchSpawn( npc )

	npc.SetMaxHealth( 100 )
	npc.SetHealth( 100 )

	npc.SetModel( $"models/humans/pilots/pilot_light_ged_m.mdl" )
	vector forwardVector = AnglesToForward( npc.GetAngles() )
	forwardVector *= 30.0
	npc.SetOrigin( player.GetOrigin() + forwardVector )
	npc.SetVelocity( player.GetVelocity() + forwardVector * 4 )
	PutEntityInSafeSpot( npc, player, null, player.GetOrigin(), npc.GetOrigin() )

	npc.SetHologram();
	npc.SetDeathActivity( "ACT_DIESIMPLE" );

	ee_name( npc )

	entity player_weapon = player.GetActiveWeapon();
	string player_weapon_name = player_weapon.GetWeaponClassName();

	array<entity> weapons = npc.GetMainWeapons()
	string weapon_name = npc.GetLatestPrimaryWeapon().GetWeaponClassName()

	npc.TakeWeaponNow( weapon_name )
	npc.GiveWeapon( player_weapon_name )
	npc.SetActiveWeaponByName( player_weapon_name )


	wait 15.0;

	if ( npc != null && IsAlive( npc ) )
	{
		TakeAllWeapons( npc )
		npc.SetHealth( 0 )
	}

#endif
}

void function ee_name( entity npc )
{
#if SERVER
	int jokechance = RandomIntRange( 1, 5 )
	int nameid = RandomIntRange( 1, 18 )

	npc.SetTitle( "Holo-pilot" )

	if ( jokechance == 1 )
	{
		switch ( nameid )
		{
			case 1:
					npc.SetTitle( "Thylord" )
				break;
			case 2:
					npc.SetTitle( "Spitfire" )
				break;
			case 3:
					npc.SetTitle( "Zevaazz" )
				break;
			case 4:
					npc.SetTitle( "Zoomerjoey" )
				break;
			case 5:
					npc.SetTitle( "BobTheBob" )
				break;
			case 6:
					npc.SetTitle( "Taskinoz" )
				break;
			case 7:
					npc.SetTitle( "AngryMichu20" )
				break;
			case 8:
					npc.SetTitle( "Swagguy47" )
				break;
			case 9:
					npc.SetTitle( "Ghxstly_Raii" )
				break;
			case 10:
					npc.SetTitle( "Neil Cicierega" )
				break;
			case 11:
					npc.SetTitle( "Joji" )
				break;
			case 12:
					npc.SetTitle( "Afourteen" )
				break;
			case 13:
					npc.SetTitle( "Thomas Bangalter" )
				break;
			case 14:
					npc.SetTitle( "Guy-Manuel" )
				break;
			case 15:
					npc.SetTitle( "Chris Christodoulou" )
				break;
			case 16:
					npc.SetTitle( "Jack Stauber" )
				break;
			case 17:
					npc.SetTitle( "Tally Hall" )
				break;
			case 18:
					npc.SetTitle( "u/IMC-Spyglass" )
				break;
		}
	}

#endif
}
