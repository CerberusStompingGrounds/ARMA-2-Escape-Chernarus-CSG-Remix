drn_fnc_Escape_GetPlayers = {
	drn_players = [];
	if (!isNil "p1") then {
		if (isPlayer p1) then {
			drn_players set [count drn_players, p1];
		};
	};
	if (!isNil "p2") then {
		if (isPlayer p2) then {
			drn_players set [count drn_players, p2];
		};
	};
	if (!isNil "p3") then {
		if (isPlayer p3) then {
			drn_players set [count drn_players, p3];
		};
	};
	if (!isNil "p4") then {
		if (isPlayer p4) then {
			drn_players set [count drn_players, p4];
		};
	};
	if (!isNil "p5") then {
		if (isPlayer p5) then {
			drn_players set [count drn_players, p5];
		};
	};
	if (!isNil "p6") then {
		if (isPlayer p6) then {
			drn_players set [count drn_players, p6];
		};
	};
	if (!isNil "p7") then {
		if (isPlayer p7) then {
			drn_players set [count drn_players, p7];
		};
	};
	if (!isNil "p8") then {
		if (isPlayer p8) then {
			drn_players set [count drn_players, p8];
		};
	};

	drn_players
};

drn_fnc_Escape_OnSpawnGeneralSoldierUnit = {
    _this setVehicleAmmo (0.2 + random 0.6);
    _this removeWeapon "ItemGPS";
    _this removeWeapon "ItemMap";
    _this removeWeapon "ItemCompass";
    _this removeWeapon "NVGoggles";

    _this setSkill (drn_var_Escape_enemyMinSkill + random (drn_var_Escape_enemyMaxSkill - drn_var_Escape_enemyMinSkill));

    if (random 100 < 30) then {
        _this addWeapon "ItemMap";
    };
    if (random 100 < 30) then {
        _this addWeapon "ItemCompass";
    };
    if (random 100 < 25) then {
        if (!(_this hasWeapon "NVGoggles")) then {
            _this addweapon "NVGoggles";
        };
    };
    if (random 100 < 10) then {
        if (!(_this hasWeapon "ItemGPS")) then {
            _this addWeapon "ItemGPS";
        };
    }
};

drn_fnc_Escape_FindGoodPos = {
    private ["_i", "_startPos", "_isOk", "_result", "_roadSegments", "_dummyObject"];

    // Choose a random and flat position (for-loopen and markers are for test on new maps).
    for [{_i = 0},  {_i < 1}, {_i = _i + 1}] do {
        _isOk = false;
        while {!_isOk} do {
            if (random 100 > 60) then {
                _startPos = + [8000 + random 5000, 4000 + random 6000]; // Most difficult place
            }
            else {
                if (random 100 > 50) then {
                    _startPos = + [4000 + random 9000, 3000 + random 6000]; // Difficult place
                }
                else {
                    _startPos = + [500 + random 12500, 500 + random 12500]; // Easiest place
                };
            };

            //diag_log ("startPos == " + str _startPos);
            _result = _startPos isFlatEmpty [0, 0, 0.25, 1, 0, false, objNull];
            _roadSegments = _startPos nearRoads 12;

            if ((count _result > 0) && (count _roadSegments == 0) && (!surfaceIsWater _startPos)) then {
                _dummyObject = "Can_small" createVehicleLocal _startPos;

                if (((nearestBuilding _dummyObject) distance _startPos) > 50) then {
                    _isOk = true;
                };

                deleteVehicle _dummyObject;
            };
        };

        //_marker = createMarker ["marker" + str _i, _startPos];
        //_marker setMarkerType "Warning";
    };

    _startPos
};

drn_fnc_Escape_FindAmmoDepotPositions = {
    private ["_occupiedPositions"];
    private ["_positions", "_i", "_j", "_tooCloseAnotherPos", "_pos", "_maxDistance", "_countNW", "_countNE", "_countSE", "_countSW", "_isOk"];

    _occupiedPositions = _this;

    _positions = [];
    _i = 0;
    _maxDistance = 500;

    _countNW = 0;
    _countNE = 0;
    _countSE = 0;
    _countSW = 0;

    while {count _positions < 10} do {
        _isOk = false;
        _j = 0;

        while {!_isOk} do {
            _pos = call drn_fnc_Escape_FindGoodPos;
            _isOk = true;

            if (count _positions < 8) then {
                if (_pos select 0 <= ((getMarkerPos "center") select 0) && _pos select 1 > ((getMarkerPos "center") select 1)) then {
                    if (_countNW < 2) then {
                        _countNW = _countNW + 1;
                    }
                    else {
                        _isOk = false;
                    };
                };
                if (_pos select 0 > ((getMarkerPos "center") select 0) && _pos select 1 > ((getMarkerPos "center") select 1)) then {
                    if (_countNE < 2) then {
                        _countNE = _countNE + 1;
                    }
                    else {
                        _isOk = false;
                    };
                };
                if (_pos select 0 > ((getMarkerPos "center") select 0) && _pos select 1 <= ((getMarkerPos "center") select 1)) then {
                    if (_countSE < 2) then {
                        _countSE = _countSE + 1;
                    }
                    else {
                        _isOk = false;
                    };
                };
                if (_pos select 0 <= ((getMarkerPos "center") select 0) && _pos select 1 <= ((getMarkerPos "center") select 1)) then {
                    if (_countSW < 2) then {
                        _countSW = _countSW + 1;
                    }
                    else {
                        _isOk = false;
                    };
                };
            };

            _j = _j + 1;
            if (_j > 100) then {
                _isOk = true;
            };
        };

        _tooCloseAnotherPos = false;
        {
            if (_pos distance _x < _maxDistance) then {
                _tooCloseAnotherPos = true;
            };
        } foreach _positions;

        if (!_tooCloseAnotherPos) then {
            {
                if (_pos distance _x < _maxDistance) then {
                    _tooCloseAnotherPos = true;
                };
            } foreach _occupiedPositions;
        };

        if (!_tooCloseAnotherPos) then {
            _positions set [count _positions, _pos];
        };

        _i = _i + 1;
        if (_i > 100) exitWith {
            _positions
        };
    };

    _positions
};

drn_fnc_Escape_AllPlayersOnStartPos = {
    private ["_startPos"];
    private ["_allPlayersAtStartPos"];

    _startPos = _this select 0;

    _allPlayersAtStartPos = true;

    {
        if (_x distance _startPos > 30) exitWith {
            _allPlayersAtStartPos = false;
        };
    } foreach call drn_fnc_Escape_GetPlayers;

    _allPlayersAtStartPos
};

drn_fnc_Escape_GetPlayerGroup = {
    private ["_units", "_unit", "_group"];

    _units = call drn_fnc_Escape_GetPlayers;

    _unit = _units select 0;
    _group = group _unit;

    _group
};

drn_fnc_Escape_BuildAmmoDepot = {
    private ["_middlePos", "_staticWeaponClasses", "_parkedVehicleClasses"];
    private ["_object", "_pos", "_marker", "_instanceNo", "_randomNo", "_gun", "_angle", "_car", "_i"];

    _middlePos = _this select 0;
    _staticWeaponClasses = _this select 1;
    _parkedVehicleClasses = _this select 2;

    if (isNil "drn_BuildAmmoDepot_MarkerInstanceNo") then {
        drn_BuildAmmoDepot_MarkerInstanceNo = 0;
    }
    else {
        drn_BuildAmmoDepot_MarkerInstanceNo = drn_BuildAmmoDepot_MarkerInstanceNo + 1;
    };
    _instanceNo = drn_BuildAmmoDepot_MarkerInstanceNo;

    _pos = [(_middlePos select 0) - 4.5, (_middlePos select 1) + 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 0;

    _pos = [(_middlePos select 0) - 1.5, (_middlePos select 1) + 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 0;

    _pos = [(_middlePos select 0) + 1.5, (_middlePos select 1) + 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 0;

    _pos = [(_middlePos select 0) + 4.5, (_middlePos select 1) + 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 0;

    _pos = [(_middlePos select 0) - 6, (_middlePos select 1) - 4.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 270;

    _pos = [(_middlePos select 0) - 6, (_middlePos select 1) - 1.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 270;

    _pos = [(_middlePos select 0) - 6, (_middlePos select 1) + 1.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 270;

    _pos = [(_middlePos select 0) - 6, (_middlePos select 1) + 4.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 270;

    _pos = [(_middlePos select 0) - 4.5, (_middlePos select 1) - 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 180;

    /*
    _pos = [(_middlePos select 0) - 1.5, (_middlePos select 1) - 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 180;

    _pos = [(_middlePos select 0) + 1.5, (_middlePos select 1) - 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 180;
    */

    _pos = [(_middlePos select 0) + 4.5, (_middlePos select 1) - 6, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 180;

    _pos = [(_middlePos select 0) + 6, (_middlePos select 1) - 4.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    _pos = [(_middlePos select 0) + 6, (_middlePos select 1) - 1.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    _pos = [(_middlePos select 0) + 6, (_middlePos select 1) + 1.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    _pos = [(_middlePos select 0) + 6, (_middlePos select 1) + 4.5, 0];
    _object = "Fence_Ind" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    // Tunnor
    _pos = [(_middlePos select 0) + 7, (_middlePos select 1) - 5, 0];
    _object = "Land_Fire_barrel_burning" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    _pos = [(_middlePos select 0) - 5, (_middlePos select 1) + 7, 0];
    _object = "Land_Fire_barrel_burning" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    // Flagga

    _pos = [(_middlePos select 0) + 3.2, (_middlePos select 1) - 6.5, 0];
    _object = "FlagCarrierINS" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    _pos = [(_middlePos select 0) - 3, (_middlePos select 1) - 6.3, 0];
    _object = "FlagCarrierINS" createVehicle _pos;
    _object setPos _pos;
    _object setDir 90;

    // Skylt

    _pos = [(_middlePos select 0) + 3, (_middlePos select 1) - 7, 0];
    _object = "Sign_MP_op" createVehicle _pos;
    _object setPos _pos;
    _object setDir 340;

    _pos = [(_middlePos select 0) - 3, (_middlePos select 1) - 7, 0];
    _object = "Sign_MP_op" createVehicle _pos;
    _object setPos _pos;
    _object setDir 20;

    // Statics

    if (count _staticWeaponClasses > 0) then {
        _gun = _staticWeaponClasses select floor random count _staticWeaponClasses;

        _randomNo = random 100;
        _pos = [(_middlePos select 0) + 10, (_middlePos select 1) + 10, 0];
        _angle = 45;

        if (_randomNo > 25) then {
            _pos = [(_middlePos select 0) + 10, (_middlePos select 1) - 10, 0];
            _angle = 135
        };
        if (_randomNo > 50) then {
            _pos = [(_middlePos select 0) - 10, (_middlePos select 1) - 10, 0];
            _angle = 225
        };
        if (_randomNo > 75) then {
            _pos = [(_middlePos select 0) - 10, (_middlePos select 1) + 10, 0];
            _angle = 315
        };

        _object = _gun createVehicle _pos;
        _object setPos _pos;
        _object setDir _angle;
    };

    // Cars

    if (random 10 > 1 && count _parkedVehicleClasses > 0) then {
        _car = _parkedVehicleClasses select floor random count _parkedVehicleClasses;
    }
    else {
        _car = "";
    };

    if (_car != "") then {
        _randomNo = random 4;
        _pos = [(_middlePos select 0) + 8, (_middlePos select 1), 0];
        _angle = 45;
        if ((random 100) > 50) then {_angle = 0;} else {_angle = 180;};

        if (_randomNo > 2) then {
            _pos = [(_middlePos select 0) - 8, (_middlePos select 1), 0];
            if ((random 100) > 50) then {_angle = 0;} else {_angle = 180;};
        };
        if (_randomNo > 3) then {
            _pos = [(_middlePos select 0), (_middlePos select 1) + 8, 0];
            if ((random 100) > 50) then {_angle = 90;} else {_angle = 270;};
        };

        _object = _car createVehicle _pos;
        _object setPos _pos;
        _object setDir _angle;
    };

    // Weapons

    // Ammo that will always be there
    for [{_i = 0}, {_i < count drn_arr_AmmoClassAlwaysInAmmoDepots}, {_i = _i + 1}] do {
        (drn_arr_AmmoClassAlwaysInAmmoDepots select _i) createVehicle _middlePos;
    };

    // Ammo that maybe will be at ammo depot (40% chance).
    for [{_i = 0}, {_i < count drn_arr_AmmoClassMaybeInAmmoDepots}, {_i = _i + 1}] do {
        if (random 100 < 40) then {
            (drn_arr_AmmoClassMaybeInAmmoDepots select _i) createVehicle _middlePos;
        };
    };

    // Set markers

    _marker = createMarker ["drn_AmmoDepotMapMarker" + str _instanceNo, _middlePos];
    _marker setMarkerType "Depot";

    _marker = createMarkerLocal ["drn_AmmoDepotPatrolMarker" + str _instanceNo, _middlePos];
    _marker setMarkerShapeLocal "ELLIPSE";
    _marker setMarkerAlpha 0;
    _marker setMarkerSizeLocal [50, 50];
};

drn_fnc_Escape_CreateExtractionPointServer = {
    private ["_extractionPointNo"];

    _extractionPointNo = _this select 0;

    if (isServer) then {
        [_extractionPointNo] execVM "Scripts\Escape\CreateExtractionPoint.sqf";
    }
    else {
        drn_EscapeExtractionEventArgs = [_extractionPointNo];
        publicVariable "drn_EscapeExtractionEventArgs";
    };
};

if (isServer) then {
    "drn_EscapeExtractionEventArgs" addPublicVariableEventHandler {
        drn_EscapeExtractionEventArgs call drn_fnc_Escape_CreateExtractionPointServer;
    };
};

drn_Escape_AskForTimeSynchronizationEventArgs = [];
drn_Escape_SynchronizeTimeEventArgs = [];

drn_fnc_Escape_SynchronizeTimeLocal = {
    setDate _this;
};

drn_fnc_Escape_AskForTimeSynchronization = {
    drn_Escape_AskForTimeSynchronizationEventArgs = [true];
    publicVariable "drn_Escape_AskForTimeSynchronizationEventArgs";
};

"drn_Escape_SynchronizeTimeEventArgs" addPublicVariableEventHandler {
    drn_Escape_SynchronizeTimeEventArgs call drn_fnc_Escape_SynchronizeTimeLocal;
};

if (isServer) then {
    drn_fnc_Escape_SynchronizeTimeAllClients = {
        drn_Escape_SynchronizeTimeEventArgs = + date;
        publicVariable "drn_Escape_SynchronizeTimeEventArgs";
    };

    "drn_Escape_AskForTimeSynchronizationEventArgs" addPublicVariableEventHandler {
        call drn_fnc_Escape_SynchronizeTimeAllClients;
    };
};

drn_fnc_Escape_TrafficSearch = {
    private ["_vehicle", "_referenceMarker", "_distanceFromReferenceMarker", "_minTimeBetweenStopsSek", "_maxTimeBetweenStopsSek"];
    private ["_gunner", "_commander", "_angle", "_i", "_startSearchTime", "_searchTime", "_glanceTime", "_startGlanceTime", "_turnDir", "_startTime", "_waitTime", "_detectedEnemies"];
    private ["_fnc_LookInDirection", "_fnc_hasDetectedEnemies"];

    _vehicle = _this select 0;
    _referenceMarker = drn_searchAreaMarkerName;
    _distanceFromReferenceMarker = 1000;
    _minTimeBetweenStopsSek = 30;
    _maxTimeBetweenStopsSek = 180;

    scopeName "mainScope";
    _gunner = gunner _vehicle;
    _commander = commander _vehicle;
    _angle = 0;

    {
        _x call drn_fnc_Escape_OnSpawnGeneralSoldierUnit;
    } foreach units group _vehicle;

    if ((isNull _gunner) && (isNull _commander)) exitWith {};

    _fnc_LookInDirection = {
        private ["_unit", "_dir"];
        private ["_x", "_y", "_pos"];

        _unit = _this select 0;
        _dir = _this select 1;

        _x = ((getPos _unit) select 0) - (1000 * cos (_dir + 90));
        _y = ((getPos _unit) select 1) + (1000 * sin (_dir + 90));
        _pos = [_x, _y, 0];

        _unit doWatch _pos;

//        deleteMarkerLocal "debugMarker";
//        _marker = createMarkerLocal ["debugMarker", _pos];
//        _marker setMarkerTypeLocal "Warning";
    };

    _fnc_hasDetectedEnemies = {
        private ["_unit"];
        private ["_nearestEnemy", "_result"];

        _unit = _this select 0;

        _nearestEnemy = _unit findNearestEnemy (getPos _unit);
        _result = false;

        if (!isNull _nearestEnemy) then {
            _result = true;
        };

        _result
    };

    sleep (_minTimeBetweenStopsSek + random (_maxTimeBetweenStopsSek - _minTimeBetweenStopsSek));
    _detectedEnemies = false;

    while {damage _vehicle < 0.1 && !_detectedEnemies} do {
        private ["_pos", "_makeSearchStop"];

        _makeSearchStop = true;
        if (_referenceMarker != "") then {
            if ((getMarkerPos _referenceMarker) distance _vehicle > _distanceFromReferenceMarker) then {
                _makeSearchStop = false;
            };
        };

        if (_makeSearchStop) then {
            _startSearchTime = time;
            _searchTime = 15 + random 30;
            _turnDir = [1, -1] select floor random 2;
            _angle = getDir _vehicle;
            while {time < _startSearchTime + _searchTime} do {
                _glanceTime = 1 + random 6;
                _startGlanceTime = time;
                _i = 0;
                while {time < _startGlanceTime + _glanceTime} do {
                    if (!isNull _gunner) then {
                        if ([_gunner] call _fnc_hasDetectedEnemies) then {
                            _detectedEnemies = true;
                            breakTo "mainScope";
                        };
                        if (_i == 0) then {
                            [_gunner, _angle] call _fnc_LookInDirection;
                        };
                    };
                    if (!isNull _commander) then {
                        if ([_commander] call _fnc_hasDetectedEnemies) then {
                            _detectedEnemies = true;
                            breakTo "mainScope";
                        };
                        if (_i == 0) then {
                            [_commander, _angle] call _fnc_LookInDirection;
                        };
                    };

                    _vehicle limitSpeed 0;
                    sleep 0.05;
                    _i = _i + 1;
                };

                _angle = _angle + (10 + random 120) * _turnDir;
                if (_angle > 360) then {
                    _angle = _angle - 360;
                };
            };

            if (!isNull _gunner) then {
                [_gunner, getDir _vehicle] call _fnc_LookInDirection;
            };
            if (!isNull _commander) then {
                [_commander, getDir _vehicle] call _fnc_LookInDirection;
            };

            _startTime = time;
            _waitTime = 2;
            while {time < _startTime + _waitTime} do {
                _vehicle limitSpeed 0;
                sleep 0.05;
            };

            if (!isNull _gunner) then {
                if ([_gunner] call _fnc_hasDetectedEnemies) then {
                    _detectedEnemies = true;
                    breakTo "mainScope";
                };
            };
            if (!isNull _commander) then {
                if ([_commander] call _fnc_hasDetectedEnemies) then {
                    _detectedEnemies = true;
                    breakTo "mainScope";
                };
            };

            if (!isNull _gunner) then {
                _gunner doWatch objNull;
            };
            if (!isNull _commander) then {
                _commander doWatch objNull;
            };

            _startTime = time;
            _waitTime = 2;
            while {time < _startTime + _waitTime} do {
                _vehicle limitSpeed 0;
                sleep 0.05;
            };
        };

        _startTime = time;
        _waitTime = _minTimeBetweenStopsSek + random (_maxTimeBetweenStopsSek - _minTimeBetweenStopsSek);
        while {time < _startTime + _waitTime} do {
            if (!isNull _gunner) then {
                if ([_gunner] call _fnc_hasDetectedEnemies) then {
                    _detectedEnemies = true;
                    breakTo "mainScope";
                };
            };
            if (!isNull _commander) then {
                if ([_commander] call _fnc_hasDetectedEnemies) then {
                    _detectedEnemies = true;
                    breakTo "mainScope";
                };
            };

            sleep 5;
        };
    };

    if (_detectedEnemies) then {
        (group _vehicle) setBehaviour "COMBAT";
        (group _vehicle) setCombatMode "RED";
    };
};

drn_fnc_Escape_SetMissionCompleteTasks = {
    if (!isServer) exitWith {};

    // Hijack Communication Center
    if (drn_hijackTasksStatus == "SUCCEEDED") then {
        ["drn_hijackTasks", "SUCCEEDED"] call drn_SetTaskStateOnAllMachines;
    }
    else {
        ["drn_hijackTasks", "FAILED"] call drn_SetTaskStateOnAllMachines;
    };

    // Rendezvous
    if (drn_rendesvouzTasksStatus == "SUCCEEDED") then {
        ["drn_rendesvouzTasks", "SUCCEEDED"] call drn_SetTaskStateOnAllMachines;
    }
    else {
        ["drn_rendesvouzTasks", "FAILED"] call drn_SetTaskStateOnAllMachines;
    };
};

drn_fnc_Escape_AddRemoveComCenArmor = {
    private ["_comCenArmorIndex", "_armorClasses", "_armorObjects"];
    private ["_comCenArmorItem", "_result", "_pos", "_crew"];

    _comCenArmorIndex = _this select 0;

    _comCenArmorItem = drn_arr_Escape_ComCenArmors select _comCenArmorIndex;

    _pos = _comCenArmorItem select 0;
    _armorClasses = _comCenArmorItem select 1;
    _armorObjects = _comCenArmorItem select 2;

    if (count _armorObjects == 0) then {
        private ["_spawnedArmors", "_vehicle", "_group", "_waypoint", "_roadSegments", "_spawnPos"];

        _spawnedArmors = [];

        {
            _roadSegments = (_pos nearRoads 100);
            _spawnPos = getPos (_roadSegments select floor random count _roadSegments);

            _result = [_spawnPos, 0, _x, east] call BIS_fnc_spawnVehicle;
            _vehicle = _result select 0;
            _crew = _result select 1;
            _group = _result select 2;

            {
                _x call drn_fnc_Escape_OnSpawnGeneralSoldierUnit;
            } foreach _crew;

            _waypoint = _group addWaypoint [_pos, 70];
            _waypoint setWaypointType "GUARD";
            _waypoint setWaypointBehaviour "AWARE";
            _waypoint setWaypointCombatMode "YELLOW";

            _spawnedArmors set [count _spawnedArmors, _vehicle];
        } foreach _armorClasses;

        _comCenArmorItem set [2, _spawnedArmors];
    }
    else {
        private ["_group"];

        {
            _group = group _x;

            {
                deleteVehicle _x;
            } foreach crew _x;

            deleteVehicle _x;
            deleteGroup _group;
        } foreach _armorObjects;

        _comCenArmorItem set [2, []];
    };
};

drn_fnc_Escape_InitializeComCenArmor = {
    private ["_referenceGroup", "_comCenPositions", "_enemySpawnDistance", "_enemyFrequency"];
    private ["_index", "_pos", "_trigger"];

    _referenceGroup = _this select 0;
    _comCenPositions = _this select 1;
    _enemySpawnDistance = _this select 2;
    _enemyFrequency = _this select 3;

    drn_arr_Escape_ComCenArmors = [];
    _index = 0;

    {
        _pos = _x;

        switch (_enemyFrequency) do
        {
            case 1:
            {
                drn_arr_Escape_ComCenArmors set [count drn_arr_Escape_ComCenArmors, [_pos, [drn_arr_ComCenDefence_lightArmorClasses select floor random count drn_arr_ComCenDefence_lightArmorClasses], []]];
            };
            case 2:
            {
                drn_arr_Escape_ComCenArmors set [count drn_arr_Escape_ComCenArmors, [_pos, [drn_arr_ComCenDefence_heavyArmorClasses select floor random count drn_arr_ComCenDefence_heavyArmorClasses], []]];
            };
            default
            {
                drn_arr_Escape_ComCenArmors set [count drn_arr_Escape_ComCenArmors, [_pos, [drn_arr_ComCenDefence_lightArmorClasses select floor random count drn_arr_ComCenDefence_lightArmorClasses, drn_arr_ComCenDefence_heavyArmorClasses select floor random count drn_arr_ComCenDefence_heavyArmorClasses], []]];
            };
        };

        _trigger = createTrigger["EmptyDetector", _pos];
        _trigger triggerAttachVehicle [units _referenceGroup select 0];
        _trigger setTriggerArea[_enemySpawnDistance + 50, _enemySpawnDistance + 50, 0, false];
        _trigger setTriggerActivation["MEMBER", "PRESENT", true];
        _trigger setTriggerTimeout [2, 2, 2, true];
        _trigger setTriggerStatements["this", "_nil = [" + str _index + "] spawn drn_fnc_Escape_AddRemoveComCenArmor;", "_nil = [" + str _index + "] spawn drn_fnc_Escape_AddRemoveComCenArmor;"];

        _index = _index + 1;
    } foreach _comCenPositions;
};

drn_fnc_Escape_FindSpawnSegment = {
    private ["_referenceGroup", "_minSpawnDistance", "_maxSpawnDistance"];
    private ["_refUnit", "_roadSegments", "_roadSegment", "_isOk", "_tries", "_result", "_spawnDistanceDiff", "_refPosX", "_refPosY", "_dir", "_tooFarAwayFromAll", "_tooClose"];

    _referenceGroup = _this select 0;
    _minSpawnDistance = _this select 1;
    _maxSpawnDistance = _this select 2;

    _spawnDistanceDiff = _maxSpawnDistance - _minSpawnDistance;
    _roadSegment = "NULL";
    _refUnit = vehicle ((units _referenceGroup) select floor random count units _referenceGroup);

    _isOk = false;
    _tries = 0;
    while {!_isOk && _tries < 25} do {
        _isOk = true;

        _dir = random 360;
        _refPosX = ((getPos _refUnit) select 0) + (_minSpawnDistance + _spawnDistanceDiff) * sin _dir;
        _refPosY = ((getPos _refUnit) select 1) + (_minSpawnDistance + _spawnDistanceDiff) * cos _dir;

        _roadSegments = [_refPosX, _refPosY] nearRoads (_spawnDistanceDiff);

        if (count _roadSegments > 0) then {
            _roadSegment = _roadSegments select floor random count _roadSegments;

            // Check if road segment is at spawn distance
            _tooFarAwayFromAll = true;
            _tooClose = false;
            {
                private ["_tooFarAway"];

                _tooFarAway = false;

                if ((vehicle _x) distance (getPos _roadSegment) < _minSpawnDistance) then {
                    _tooClose = true;
                };
                if ((vehicle _x) distance (getPos _roadSegment) > _maxSpawnDistance) then {
                    _tooFarAway = true;
                };
                if (!_tooFarAway) then {
                    _tooFarAwayFromAll = false;
                };

            } foreach units _referenceGroup;

            _isOk = true;
            if (_tooClose || _tooFarAwayFromAll) then {
                _isOk = false;
                _tries = _tries + 1;
            };
        }
        else {
            _isOk = false;
            _tries = _tries + 1;
        };
    };

    if (!_isOk) then {
        _result = "NULL";
    }
    else {
        _result = _roadSegment;
    };

    _result
};

drn_fnc_Escape_PopulateVehicle = {
    private ["_vehicle", "_side", "_unitTypes", "_enemyFrequency"];
    private ["_group", "_maxSoldiersCount", "_soldierCount", "_continue", "_unitType", "_insurgentSoldier"];

    _vehicle = _this select 0;
    _side = _this select 1;
    _unitTypes = _this select 2;
    if (count _this > 3) then { _enemyFrequency = _this select 3; } else { _enemyFrequency = 3; };

    _maxSoldiersCount = _enemyFrequency + 3 + floor random (4 * _enemyFrequency);
    _group = createGroup _side;

    _soldierCount = 0;

    // Driver
    _continue = true;
    while {_continue && (_soldierCount <= _maxSoldiersCount)} do {
        _unitType = _unitTypes select floor random count _unitTypes;
        _insurgentSoldier = _group createUnit [_unitType, [0,0,0], [], 0, "FORM"];

        _insurgentSoldier setRank "LIEUTNANT";
        _insurgentSoldier moveInDriver _vehicle;

        if (vehicle _insurgentSoldier != _insurgentSoldier) then {
            _insurgentSoldier assignAsDriver _vehicle;
            _soldierCount + _soldierCount + 1;
        }
        else {
            deleteVehicle _insurgentSoldier;
            _continue = false;
        };
    };

    // Gunner
    _continue = true;
    while {_continue && _soldierCount <= _maxSoldiersCount} do {
        _unitType = _unitTypes select floor random count _unitTypes;
        _insurgentSoldier = _group createUnit [_unitType, [0,0,0], [], 0, "FORM"];

        _insurgentSoldier setRank "LIEUTNANT";
        _insurgentSoldier moveInGunner _vehicle;

        if (vehicle _insurgentSoldier != _insurgentSoldier) then {
            _insurgentSoldier assignAsGunner _vehicle;
            _soldierCount + _soldierCount + 1;
        }
        else {
            deleteVehicle _insurgentSoldier;
            _continue = false;
        };
    };

    // Commander
    _continue = true;
    while {_continue && _soldierCount <= _maxSoldiersCount} do {
        _unitType = _unitTypes select floor random count _unitTypes;
        _insurgentSoldier = _group createUnit [_unitType, [0,0,0], [], 0, "FORM"];

        _insurgentSoldier setRank "LIEUTNANT";
        _insurgentSoldier moveInCommander _vehicle;

        if (vehicle _insurgentSoldier != _insurgentSoldier) then {
            _insurgentSoldier assignAsCommander _vehicle;
            _soldierCount + _soldierCount + 1;
        }
        else {
            deleteVehicle _insurgentSoldier;
            _continue = false;
        };
    };

    // Cargo
    _continue = true;
    while {_continue && _soldierCount <= _maxSoldiersCount} do {
        _unitType = _unitTypes select floor random count _unitTypes;
        _insurgentSoldier = _group createUnit [_unitType, [0,0,0], [], 0, "FORM"];

        _insurgentSoldier setRank "LIEUTNANT";
        _insurgentSoldier moveInCargo _vehicle;

        if (vehicle _insurgentSoldier != _insurgentSoldier) then {
            _insurgentSoldier assignAsCargo _vehicle;
            _soldierCount + _soldierCount + 1;
        }
        else {
            deleteVehicle _insurgentSoldier;
            _continue = false;
        };
    };

    _group
};

if (isServer) then {
    "drn_fnc_Escape_AskForJipPos" addPublicVariableEventHandler {
        private ["_anotherPlayer"];

        _unitName = drn_fnc_Escape_AskForJipPos select 0;

        _anotherPlayer = (call drn_fnc_Escape_GetPlayers) select 0;
        if (_unitName == str _anotherPlayer) then {
            _anotherPlayer = (call drn_fnc_Escape_GetPlayers) select 1;
        };

        _pos = [((getPos vehicle _anotherPlayer) select 0) + 3, ((getPos vehicle _anotherPlayer) select 1) + 3, 0];

        drn_arr_JipSpawnPos = [_unitName, _pos];
        publicVariable "drn_arr_JipSpawnPos";

        diag_log ("Server respond to JIP, pos == " + str getPos _anotherPlayer);
    };

    drn_var_Escape_FunctionsInitializedOnServer = true;
    publicVariable "drn_var_Escape_FunctionsInitializedOnServer";
};


