// by commy2

private ["_count", "_index", "_action", "_subMenu"];

AGM_Interaction_Buttons = [];
uiNamespace setVariable ["AGM_Interaction_CursorPosition", [controlNull, 0.5, 0.5, -1]];

_actions = [];
_patches = [];
_class = _this select 0;

_object = vehicle player;



// fix inheritance
_configClass = configFile >> "CfgVehicles" >> typeOf _object >> "AGM_SelfActions" >> _class;

_fnc_GetActions = {
	_parents = _this select 0;
	_actions = _this select 1;
	_patches = _this select 2;
	_class = _this select 3;
	_baseConfig = _this select 4;
	
	{
		_config = _baseConfig >> _x >> "AGM_SelfActions" >> _class;

		_count = count _config;
		if (_count > 0) then {
			for "_index" from 0 to (_count - 1) do {
				_action = [];
				if (_this select 5) then {
					_action = _config select _index;
				}else {
					_action = (_this select 6) >> configName (_config select _index);
				};

				if (count _action > 0) then {
					_configName = configName _action;
					_displayName = getText (_action >> "displayName");

					_condition = getText (_action >> "condition");
					if (_condition == "") then {_condition = "true"};

					_condition = _condition + format [" && {%1 call AGM_Core_canInteract}", getArray (_action >> "exceptions")];
					_condition = compile _condition;
					_showDisabled = getNumber (_action >> "showDisabled") == 1;
					if (isText (_action >> "conditionShow")) then {
						_showDisabled = call compile getText (_action >> "conditionShow");
					};
					_priority = getNumber (_action >> "priority");
					_subMenu = getArray (_action >> "subMenu");
					_tooltip = getText (_action >> "tooltip");
					_statement = {};
					
					if (profileNamespace getVariable ["AGM_Interaction_FlowMenu", false]) then {
						if (getText (_action >> "statement") == "" && {count _subMenu > 1}) then {
							_statement = compile format ["call AGM_Interaction_fnc_hideMenu;if(%2 == 1)then{['%1'] call AGM_Interaction_fnc_openSubMenuSelf;}else{'%1' call AGM_Interaction_fnc_openSubMenu;};", _subMenu select 0, _subMenu select 1];
						}else{
							_statement = compile ("call AGM_Interaction_fnc_hideMenu;" + getText (_action >> "statement"));
						};
					}else{
						_statement = compile (getText (_action >> "statement"));
					};
					
					_icon = getText(_action >> "Icon");
					if (_icon == "") then {
						_icon = "AGM_Interaction\UI\dot_ca.paa";
					};

					if (!(_configName in _patches) && {_showDisabled || {call _condition}}) then {
						_actions set [count _actions, [_displayName, _statement, _condition, _priority, _subMenu, _icon, _tooltip]];
						_patches set [count _patches, _configName];
					};
				};
			};
		};
	} forEach _parents;
	
	[_actions, _patches]
};

_parents = [configfile >> "CfgVehicles" >> typeOf _object, true] call BIS_fnc_returnParents;
_result = [_parents, [], [], _class, missionConfigFile >> "CfgVehicles", true] call _fnc_GetActions;
_result = [_parents, _result select 0, _result select 1, _class, configfile >> "CfgVehicles", false, _configClass] call _fnc_GetActions;
_actions = _result select 0;

// search vehicle namespace
_customActions = player getVariable ["AGM_InteractionsSelf", []];
for "_index" from 0 to (count _customActions - 1) do {
	_customAction = _customActions select _index;
	_displayName = _customAction select 0;

	_condition = _customAction select 1;
	_statement = _customAction select 2;
	_showDisabled = _customAction select 3;
	_priority = _customAction select 4;
	_subMenu = [];
	_icon = "AGM_Interaction\UI\dot_ca.paa";

	if (_showDisabled || {call _condition}) then {
		_actions set [count _actions, [_displayName, _statement, _condition, _priority, _subMenu, _icon]];
	};
};

_count = count _actions;
if (_count == 0) exitWith {};

_actions call AGM_Interaction_fnc_sortOptionsByPriority;
AGM_Interaction_Buttons = _actions;

[{"" call AGM_Interaction_fnc_openMenuSelf;}, true, (profileNamespace getVariable ["AGM_Interaction_FlowMenu", false]), true, _object] call AGM_Interaction_fnc_initialiseInteraction;
