/*
 * Author: CAA-Picard, commy2
 *
 * Cycle through frags.
 *
 * Argument:
 * None
 *
 * Return value:
 * None
 */

private ["_player"];

_player = _this select 0;

// Check which is the next muzzle which the player has magazines for
_nextIndex = AGM_WeaponSelect_AllMuzzles find ([AGM_WeaponSelect_CurrentGrenadeMuzzleOther, AGM_WeaponSelect_CurrentGrenadeMuzzleFrag] select AGM_WeaponSelect_CurrentGrenadeMuzzleIsFrag);

_numberChecked = 0;
_numberOfMagazines = 0;
_firstMagazine = "";
while  {(_numberChecked < count AGM_WeaponSelect_AllMuzzles) and _numberOfMagazines == 0} do {
  _nextIndex = _nextIndex + 1;
  if (_nextIndex >= count AGM_WeaponSelect_AllMuzzles) then {_nextIndex = 0};

  // Count if player has any magazines from this muzzle
  _result = [_player, AGM_WeaponSelect_AllMuzzles select _nextIndex] call AGM_WeaponSelect_fnc_countMagazinesForGrenadeMuzzle;
  _numberOfMagazines = _result select 0;
  _firstMagazine = _result select 1;

  _numberChecked = _numberChecked + 1;
};

if (_numberOfMagazines > 0) then {
  // There is a muzzle with magazines --> cycle to it
  AGM_WeaponSelect_CurrentGrenadeMuzzleFrag = AGM_WeaponSelect_AllMuzzles select _nextIndex;
  AGM_WeaponSelect_CurrentGrenadeMuzzleOther = AGM_WeaponSelect_AllMuzzles select _nextIndex;
  [_firstMagazine, _numberOfMagazines] call AGM_WeaponSelect_fnc_displayGrenadeTypeAndNumber;

  // Select the correct muzzle
  [_player, AGM_WeaponSelect_AllMuzzles select _nextIndex] call AGM_WeaponSelect_fnc_setNextGrenadeMuzzle;

} else {
  // There is a no muzzle with magazines --> select nothing
  AGM_WeaponSelect_CurrentGrenadeMuzzleFrag = "";
  AGM_WeaponSelect_CurrentGrenadeMuzzleOther = "";

  _text = [localize "STR_AGM_WeaponSelect_NoGrenadesLeft", [1,0,0]] call AGM_Core_fnc_stringToColoredText;
  [composeText [lineBreak, _text]] call AGM_Core_fnc_displayTextStructured;
};

AGM_WeaponSelect_CurrentGrenadeMuzzleIsFrag = AGM_WeaponSelect_CurrentGrenadeMuzzleFrag in AGM_WeaponSelect_FragMuzzles;