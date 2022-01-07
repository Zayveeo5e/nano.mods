global function OnWeaponPrimaryAttack_ability_stim_super

var function OnWeaponPrimaryAttack_ability_stim_super( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )
	if ( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	{
		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_CLASSIC_MP_SPAWNING )
			return false

		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_INTRO )
			return false
	}

	float duration = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
	
	float speed = 0.5
	
	if ( weapon.HasMod( "stim_0x_speed" ) )
	{
		speed = 0.0
	}	
	
	if ( weapon.HasMod( "stim_2x_speed" ) )
	{
		speed = 1.0
	}
	
	if ( weapon.HasMod( "stim_4x_speed" ) )
	{
		speed = 2.0
	}
	
	Super_StimPlayer( ownerPlayer, duration, speed )

	PlayerUsedOffhand( ownerPlayer, weapon )

#if SERVER
#if BATTLECHATTER_ENABLED
	TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
#endif //
#else //
	Rumble_Play( "rumble_stim_activate", {} )
#endif //

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}

//actual stim code

void function Super_StimPlayer( entity player, float duration, float severity )
{
	StimPlayer_Internal( player, duration, severity )
}

void function StimPlayer_Internal( entity player, float duration, float effectSeverity )
{
	StatusEffect_AddTimed( player, eStatusEffect.speed_boost, effectSeverity, duration + 0.5, 0.25 ) // sound is slightly off
	StatusEffect_AddTimed( player, eStatusEffect.stim_visual_effect, 1.0, duration, duration )

#if SERVER
	thread Super_StimThink( player, duration )
#else
	entity cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	HealthHUD_ClearFX( player )
#endif
}

#if SERVER
void function Super_StimThink( entity player, float duration )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnChangedPlayerClass" )

	EmitSoundOnEntityOnlyToPlayer( player, player, "pilot_stimpack_loop_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "pilot_stimpack_loop_3P" )

	int attachmentIndex = player.LookupAttachment( "CHESTFOCUS" )

	entity stimFX = StartParticleEffectOnEntity_ReturnEntity( player, PILOT_STIM_HLD_FX, FX_PATTACH_POINT_FOLLOW, attachmentIndex )
	stimFX.SetOwner( player )
	stimFX.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY) // not owner only

	//thread StimSlowmoAim( player, duration )

	OnThreadEnd(
		function() : ( player, stimFX )
		{
			if ( !IsValid( player ) )
				return

			if ( IsValid( stimFX ) )
				EffectStop( stimFX )

			StopSoundOnEntity( player, "pilot_stimpack_loop_1P" )
			StopSoundOnEntity( player, "pilot_stimpack_loop_3P" )

			player.Signal( "EndStim" )
		}
	)

	wait duration - 2.0

	EmitSoundOnEntityOnlyToPlayer( player, player, "pilot_stimpack_deactivate_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "pilot_stimpack_deactivate_3P" )

	wait 2.0
}
#endif