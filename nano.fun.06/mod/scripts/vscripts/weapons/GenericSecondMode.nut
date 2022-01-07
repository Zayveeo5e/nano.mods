/*

"OnWeaponStartZoomIn" 							"OnWeaponStartZoomIn_GenericSecondMode"
"OnWeaponStartZoomOut" 							"OnWeaponStartZoomOut_GenericSecondMode"

*/

global function OnWeaponStartZoomIn_GenericSecondMode
global function OnWeaponStartZoomOut_GenericSecondMode

void function OnWeaponStartZoomIn_GenericSecondMode( entity weapon )
{

	if ( !weapon.HasMod( "SecondMode" ) )
	{
		array<string> mods = weapon.GetMods()
		mods.append( "SecondMode" )
		weapon.SetMods( mods )
	}
}

void function OnWeaponStartZoomOut_GenericSecondMode( entity weapon )
{
	if ( weapon.HasMod( "SecondMode" ) )
	{
		array<string> mods = weapon.GetMods()
		mods.fastremovebyvalue( "SecondMode" )
		weapon.SetMods( mods )
	}

}