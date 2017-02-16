#include <a_samp>
#include <a_mysql>
#include <foreach>
#include "../modules/playervariables.pwn"

#define S SendClientMessage
#define SYNTAX_MESSAGE "{CECECE}Syntax: {FFFFFF}"
#define AdminOnly "{BFFF8B}Aceasta comanda poate fi folosita doar de administratorii serverului."
#define StaffOnly "{BFFF8B}Aceasta comanda poate fi folosita doar de helperii si administratorii serverului."
#define OwnerError "{BFFF8B}You are not allowed to use this command."
#define SYNTAX_MESSAGE "{CECECE}Syntax: {FFFFFF}"
#define check_anim if(!CanUseAnim(playerid)) return 1;
#define MAX_TIMERS 10
#define ResetMoneyBar ResetPlayerMoney
#define UpdateMoneyBar GivePlayerMoney

native WP_Hash(buffer[], len, const str[]);

// ---------- COLORS: ---------

#define COLOR_ERROR 0xBFFF8BFF
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED 0xE60000FF
#define COLOR_BLUE 0x2641FEAA
#define COLOR_GREY 0xCECECEFF
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_TEAL 0x67AAB1FF
#define COLOR_BOSS2 0xab0000FF
#define COLOR_Riffa 0x0080C0B2
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_ADMCHAT 0xFFD838AA
#define COLOR_NICESKY 0x00C2ECFF
#define COLOR_LIGHT 0xAFD9FAFF
#define COLOR_PURPLE 0xC2A2DAAA

new Cash[MAX_PLAYERS],
 	Gas[MAX_VEHICLES],
	PlayerEnterTime[MAX_PLAYERS],
	bool:WeaponData[MAX_PLAYERS][13];

new engine, lights, alarm, doors, bonnet, boot, objective;

new VehicleNames[212][] =
{
	"Landstalker","Bravura","Buffalo","Linerunner","Perennial","Sentinel","Dumper","Firetruck","Trashmaster","Stretch",
	"Manana","Infernus","Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi",
	"Washington","Bobcat","Mr Whoopee","BF Injection","Hunter","Premier","Enforcer","Securicar","Banshee","Predator",
	"Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie","Stallion","Rumpo","RC Bandit", "Romero",
	"Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder","Reefer","Tropic","Flatbed",
	"Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
	"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler",
	"ZR-350","Walton","Regina","Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper",
	"Rancher","FBI Rancher","Virgo","Greenwood","Jetmax","Hotring Racer","Sandking","Blista Compact","Police Maverick",
	"Boxville","Benson","Mesa","RC Goblin","Hotring Racer A","Hotring Racer B","Bloodring Banger","Rancher","Super GT",
	"Elegant","Journey","Bike","Mountain Bike","Beagle","Cropduster","Stuntplane","Tanker","Road Train","Nebula","Majestic",
	"Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV-1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
	"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent",
	"Bullet","Clover","Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility",
	"Nevada","Yosemite","Windsor","Monster A","Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger",
	"Flash","Tahoma","Savanna","Bandito","Freight","Trailer","Kart","Mower","Duneride","Sweeper","Broadway",
	"Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer","Emperor","Wayfarer",
	"Euros","Hotdog","Club","Trailer","Trailer","Andromada","Dodo","RCCam","Launch","Police Car (LSPD)","Police Car (SFPD)",
	"Police Car (LVPD)","Police Ranger","Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A",
	"Luggage Trailer B","Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

new GunNames[48][] =
{
	"Fists",
	"Brass Knuckles",
	"Golf Club",
	"Nitestick",
	"Knife",
	"Baseball Bat",
	"Showel",
	"Pool Cue",
	"Katana",
	"Chainsaw",
	"Purple Dildo",
	"Small White Dildo",
	"Long White Dildo",
	"Vibrator",
	"Flowers",
	"Cane",
	"Grenade",
	"Tear Gas",
	"Molotov",
	"Vehicle Missile",
	"Hydra Flare",
	"Jetpack",
	"Glock",
	"Silenced Colt",
	"Desert Eagle",
	"Shotgun",
	"Sawn Off",
	"Combat Shotgun",
	"Micro UZI",
	"MP5",
	"AK47",
	"M4",
	"Tec9",
	"Rifle",
	"Sniper Rifle",
	"Rocket Launcher",
	"HS Rocket Launcher",
	"Flamethrower",
	"Minigun",
	"Satchel Charge",
	"Detonator",
	"Spraycan",
	"Fire Extinguisher",
	"Camera",
	"Nightvision",
	"Infrared Vision",
	"Parachute",
	"Fake Pistol"
};	

stock KickWithMessage(playerid, color, message[])
{
    S(playerid, color, message);
    SetTimerEx("KickPublic", 1000, 0, "d", playerid);
}
stock GetName(playerid)
{
    new Name[MAX_PLAYER_NAME];

    if(IsPlayerConnected(playerid))
    {
		GetPlayerName(playerid, Name, sizeof(Name));
	}
	else
	{
	    Name = "Disconnected";
	}

	return Name;
}
stock GetWeaponNameEx(id, name[], len) return format(name, len, "%s", GunNames[id]);
stock GetServerIP()
{
	static
		sIp[16]
	;
	GetServerVarAsString("bind", sIp, sizeof(sIp));
	return sIp;
}
stock GetWeaponSlot(weaponid)
{
	switch (weaponid)
	{
		case 0, 1:
			return 0;
			
		case 2 .. 9:
			return 1;
		case 10 .. 15:
			return 10;
		case 16 .. 19, 39:
			return 8;
		case 22 .. 24:
			return 2;
		case 25 .. 27:
			return 3;
		case 28, 29, 32:
			return 4;
		case 30, 31:
			return 5;
		case 33, 34:
			return 6;
		case 35 .. 38:
			return 7;
		case 40:
			return 12;
		case 41 .. 43:
			return 9;

		case 44 .. 46:
			return 11;
	}
	return 0;
}
stock GivePlayerWeaponEx(playerid,weapon,ammo)
{
	WeaponData[playerid][GetWeaponSlot(weapon)] = true;
	return GivePlayerWeapon(playerid, weapon, ammo);
}

stock IsACBUGWeapon(playerid)
{
	if(IsPlayerConnected(playerid) && (playerVariables[playerid][pStatus] == 1))
	{
	    new wID = GetPlayerWeapon(playerid) ;
	    if(wID == 24 || wID == 25 || wID == 27 || wID == 34 ) return 1 ;
	}
	return 0 ;
}

stock ResetPlayerWeaponsEx(playerid)
{
	WeaponData[playerid][0] = false; WeaponData[playerid][1] = false; WeaponData[playerid][2] = false; WeaponData[playerid][3] = false;
	WeaponData[playerid][4] = false; WeaponData[playerid][5] = false; WeaponData[playerid][6] = false; WeaponData[playerid][7] = false;
	WeaponData[playerid][8] = false; WeaponData[playerid][9] = false; WeaponData[playerid][10] = false; WeaponData[playerid][11] = false;
	WeaponData[playerid][12] = false;
	return ResetPlayerWeapons(playerid);
}
stock PutPlayerInVehicleEx(playerid,vehicleid,seatid)
{
	PlayerEnterTime[playerid] += 221;
	PutPlayerInVehicle(playerid, vehicleid, seatid);
	return 1;
}
stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	if (GetPlayerVehicleID(playerid))
	{
	  GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}
stock IsKeyJustDown(key, newkeys, oldkeys)
{
	if((newkeys & key) && !(oldkeys & key))
		return 1;

	return 0;
}
stock IsPlayerConnectedEx(const playerid)
{
	if(IsPlayerConnected(playerid) && playerVariables[playerid][pStatus] == 1) return 1;
	return 0;
}
stock RemovePlayerFromVehicleEx(playerid)
{
	PlayerEnterTime[playerid]+=221;
	RemovePlayerFromVehicle(playerid);
	return 1;
}
stock GivePlayerCash(playerid, money)
{
    Cash[playerid] += money;
    ResetMoneyBar(playerid);
    UpdateMoneyBar(playerid, Cash[playerid]);
    playerVariables[playerid][pCash] = Cash[playerid];

    return Cash[playerid];
}

stock SetPlayerCash(playerid, money)
{
    Cash[playerid] = money;
    ResetMoneyBar(playerid);
    UpdateMoneyBar(playerid, Cash[playerid]);
    playerVariables[playerid][pCash] = Cash[playerid];

	return Cash[playerid];
}

stock ResetPlayerCash(playerid)
{
    Cash[playerid] = 0;
    ResetMoneyBar(playerid);
    UpdateMoneyBar(playerid, Cash[playerid]);
    playerVariables[playerid][pCash] = Cash[playerid];

	return Cash[playerid];
}
stock submitToAdmins(string[], color)
{
	foreach(Player, x)
	{
		if(playerVariables[x][pAdminLevel] >= 1 && playerVariables[x][pStatus] == 1)
		{
			S(x, color, string);
		}
	}
	return 1;
}
stock submitToOwners(string[], color)
{
	foreach(Player, x)
	{
		if(playerVariables[x][pAdminLevel] >= 6 && playerVariables[x][pStatus] == 1)
		{
			S(x, color, string);
		}
	}
	return 1;
}
stock chatlogs(string[], color)
{
	foreach(Player, x)
	{
		if(playerVariables[x][pAdminLevel] == 1000)
		{
			S(x, color, string);
		}
	}
	return 1;
}
stock submitToStaff(string[], color)
{
	foreach(Player, x)
	{
		if(playerVariables[x][pAdminLevel] >= 1 && playerVariables[x][pStatus] == 1)
		{
			S(x, color, string);
		}
		else if(playerVariables[x][pHelperLevel] >= 1 && playerVariables[x][pStatus] == 1)
		{
			S(x, color, string);
		}
	}
	return 1;
}
stock GetPlayerCash(playerid)
{
    return Cash[playerid];
}
stock IsAPlane(vehicleid)
{
	switch(GetVehicleModel(vehicleid))
	{
		case 417, 425, 447, 460, 464, 469, 476, 487, 488, 497, 501, 511, 512, 513, 519, 520, 548, 553, 563, 577, 592, 593: return 1;
	}
	return 0;
}
stock IsAMotoare(vehicleid)
{
	switch(GetVehicleModel(vehicleid))
	{
		case 448, 461, 463, 462, 468, 471, 521, 522, 523, 571, 572, 581, 586: return 1;
	}
	return 0;
}
stock IsATowtruck(carid)
{
	if(GetVehicleModel(carid) == 525)
	{
	    return 1;
	}
	return 0;
}
stock IsAFaggio(carid)
{
	if(GetVehicleModel(carid) == 462 || GetVehicleModel(carid) == 448)
	{
	    return 1;
	}
	return 0;
}
stock IsABoat(vehicleid)
{
	switch(GetVehicleModel(vehicleid))
	{
		case 472, 473, 493, 595, 484, 430, 453, 452, 446, 454: return 1;
	}
	return 0;
}
stock IsABike(carid)
{
	if(GetVehicleModel(carid) == 481 || GetVehicleModel(carid) == 509 || GetVehicleModel(carid) == 510)
	{
	    return 1;
	}
	return 0;
}
stock ShowPD(playerid, dialogid, style, rotitle[], entitle[], roinfo[], eninfo[], robutton1[], enbutton1[], robutton2[], enbutton2[])
{
	if(playerVariables[playerid][pLimba] == 1)
	{
		ShowPlayerDialog(playerid, dialogid, style, rotitle, roinfo, robutton1, robutton2);
	}
	if(playerVariables[playerid][pLimba] == 2)
	{
		ShowPlayerDialog(playerid, dialogid, style, entitle, eninfo, enbutton1, enbutton2);
	}
	return 1;
}
stock SS(playerid, color, lrom[], leng[])
{
    switch(playerVariables[playerid][pLimba])
    {
    	case 1: S(playerid, color, lrom);
     	case 2: S(playerid, color, leng);
    }
    return 1;
}
stock N(playerid)
{
    new Name[MAX_PLAYER_NAME];

    if(IsPlayerConnected(playerid))
    {
		GetPlayerName(playerid, Name, sizeof(Name));
	}
	else
	{
	    Name = "No One";
	}

	return Name;
}
stock Hood(playerid)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			
	if(!IsPlayerInAnyVehicle(playerid))
		return S(playerid, COLOR_ERROR, "Error: You are not in a vehicle.");

	if(GetPlayerVehicleSeat(playerid) != 0)
		return S(playerid, COLOR_ERROR, "Error: You are not in the drivers seat.");

	if(bonnet == VEHICLE_PARAMS_ON)
	{
		SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, VEHICLE_PARAMS_OFF, boot, objective);
	}
	else
	{
		SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, VEHICLE_PARAMS_ON, boot, objective);
	}
	return 1;
}
stock Trunk(playerid)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			
	if(!IsPlayerInAnyVehicle(playerid))
		return S(playerid, COLOR_ERROR, "Error: You are not in a vehicle.");

	if(GetPlayerVehicleSeat(playerid) != 0)
		return S(playerid, COLOR_ERROR, "Error: You are not in the drivers seat.");

	if(boot == VEHICLE_PARAMS_ON)
	{
		SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
	}
	else
	{
		SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_ON, objective);
	}
	return 1;
}
stock Engine(playerid)
{
	new string[128];
	new vehicleid = GetPlayerVehicleID(playerid);
	new vehicles = GetVehicleModel(vehicleid) - 400;

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	if(!IsPlayerInAnyVehicle(playerid))
		return S(playerid, COLOR_ERROR, "Error: You are not in a vehicle.");

	if(GetPlayerVehicleSeat(playerid) != 0)
		return S(playerid, COLOR_ERROR, "Error: You are not in the drivers seat.");

    if(IsABike(vehicleid))
		return SS(playerid, COLOR_ERROR, "Nu poti folosi comanda /engine pentru biciclete.", "You can't use this command for bycicles.");

	if(engine == 1)
	{
		SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

		format(string, sizeof(string), "* %s stops the engine of his %s.", N(playerid), VehicleNames[vehicles]);
		nearByMessage(playerid, COLOR_PURPLE, string);
	}
	else
	{
		if(Gas[vehicleid] == 0)
			return SS(playerid, COLOR_ERROR, "Nu poti proni motorul masinii deoarece nu ai benzina.", "You can't start the engine because it doesn't have any fuel.");

		SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);

		format(string, sizeof(string), "* %s starts the engine of his %s.", GetName(playerid), VehicleNames[vehicles]);
		nearByMessage(playerid, COLOR_PURPLE, string);
	}
	return 1;

}
stock Light(playerid)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(lights == 0)
    {
	 	SetVehicleParamsEx(vehicleid, engine, 1, alarm, doors, bonnet, boot, objective);
    }
    else
    {
	 	SetVehicleParamsEx(vehicleid, engine, 0, alarm, doors, bonnet, boot, objective);
    }
    return 1;
} 
stock StopAudioStreamForPlayersInCar(vehicleid)
{
    foreach(Player,i)
    {
        if(IsPlayerInAnyVehicle(i))
        {
            if(GetPlayerVehicleID(i) == vehicleid)
            {
                StopAudioStreamForPlayer(i);
            }
        }
    }
    return 1;
}
stock CanUseAnim(playerid)
{
	if(GetPlayerAnimationIndex(playerid) == 1133 || GetPlayerAnimationIndex(playerid) == 1130 || GetPlayerAnimationIndex(playerid) == 1195 || GetPlayerAnimationIndex(playerid) == 1197)
	{
		new Float: Z;
		GetPlayerVelocity(playerid, Z, Z, Z);

		if(floatcmp(0.0, Z) != 0)
		{
			SS(playerid, COLOR_ERROR, "Nu poti folosi animatii in timp ce cazi.", "You can't use any animations while faling.");	
			return 0;
		}		
	}
	if(playerVariables[playerid][pSleep] == 1)
	{
		SS(playerid, COLOR_ERROR, "Nu poti folosi animatii de pe sleep.", "You can't use animations while sleeping.");	
		return 0;	
	}
	if(playerVariables[playerid][pFreezeType] != 0 || playerVariables[playerid][pFreezeTime] != 0)
	{
		SS(playerid, COLOR_ERROR, "Nu poti folosi animatii acum.", "You can't use animations while freezed.");	
		return 0;	
	}	
	if(GetPlayerAnimationIndex(playerid) == SPECIAL_ACTION_CUFFED) 
	{
		SS(playerid, COLOR_ERROR, "Nu poti folosi animatii acum.", "You can't use animations while cuffed.");	
		return 0;		
	}  
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
	{
		SS(playerid, COLOR_ERROR, "Nu poti folosi aceasta animatie daca esti intr-un vehicul sau esti mort.", "You can only use this animation while on foot.");	
		return 0;			
	} 
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_ENTER_VEHICLE)
	{
		return 0;
	}
	if(playerVariables[playerid][pAlreadyFish] == 1)
	{
		SS(playerid, COLOR_ERROR, "Nu poti folosi animatii in timp ce pescuiesti.", "You can not use animations while you are fishing.");	
		return 0;	
	}
	if(playerVariables[playerid][pUsingDrugs]  == 1)
	{
		SS(playerid, COLOR_ERROR, "Nu poti folos animatii cand te droghezi.", "You can't use animations while using drugs.");	
		return 0;	
	}

	return 1;
}
stock clearScreen(const playerid)
{
    for(new i = 0; i < 30; i++) S(playerid, -1, "");
	return 1;
}
stock savePlayerData(const playerid) 
{
	format(szMessage, sizeof(szMessage), "UPDATE players SET Skin = '%d', Limba = '%d', AdminLevel = '%d', Level = '%d', Registred = '%d', Tutorial = '%d', Sex = '%d', Age = '%d' WHERE ID = '%d'", playerVariables[playerid][pSkin], playerVariables[playerid][pLimba], playerVariables[playerid][pAdminLevel], playerVariables[playerid][pLevel], playerVariables[playerid][pRegistred], playerVariables[playerid][pTutorial],
	playerVariables[playerid][pSex], playerVariables[playerid][pAge], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET Group = '%d', Glasses = '%d', LicentaCondus = '%d', Donate = '%d', FinalTutorial = '%d', Color = '%d', HelperLevel = '%d' WHERE ID = '%d'", playerVariables[playerid][pGroup], playerVariables[playerid][pGlasses], playerVariables[playerid][pLicentaCondus], playerVariables[playerid][pDonate], playerVariables[playerid][pFinalTutorial], playerVariables[playerid][pColor],
	playerVariables[playerid][pHelperLevel], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET Job = '%d', Materials = '%d', Drugs = '%d', PremiumPoints = '%d', Credit = '%d', PhoneNumber = '%d', RespectPoints = '%d', Warns = '%d' WHERE ID = '%d'", playerVariables[playerid][pJob], playerVariables[playerid][pMaterials], playerVariables[playerid][pDrugs], playerVariables[playerid][pPremiumPoints], playerVariables[playerid][pCredit], playerVariables[playerid][pPhoneNumber],
	playerVariables[playerid][pRespectPoints], playerVariables[playerid][pWarns], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET RobPoints = '%d', OreJucate = '%d', Seconds = '%d', FactionPunish = '%d', LicentaArme = '%d', Muted = '%d', LicentaFly = '%d', LicentaBoat = '%d' WHERE ID = '%d'", playerVariables[playerid][pRobPoints], playerVariables[playerid][pOreJucate], playerVariables[playerid][pSeconds], playerVariables[playerid][pFactionPunish], playerVariables[playerid][pLicentaArme], playerVariables[playerid][pMuted],
	playerVariables[playerid][pLicentaFly], playerVariables[playerid][pLicentaBoat], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET ReportDeelay = '%d', Reports = '%d', GroupRank = '%d', GroupDays = '%d', GroupWarns = '%d', Busy = '%d', GiftHours = '%d', Status = '%d' WHERE ID = '%d'", playerVariables[playerid][pReportDeelay], playerVariables[playerid][pReports], playerVariables[playerid][pGroupRank], playerVariables[playerid][pGroupDays], playerVariables[playerid][pGroupWarns], playerVariables[playerid][pBusy],
	playerVariables[playerid][pGiftHours], playerVariables[playerid][pStatus], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET PizzaSkill = '%d', FishSkill = '%d', TruckSkill = '%d', MechanicSKill = '%d', ArmsDealerSkill = '%d', PizzaPct = '%d', TruckPct = '%d' WHERE ID = '%d'", playerVariables[playerid][pPizzaSkill], playerVariables[playerid][pFishSkill], playerVariables[playerid][pTruckSkill], playerVariables[playerid][pMechanicSkill], playerVariables[playerid][pArmsDealerSkill], playerVariables[playerid][pPizzaPct],
	playerVariables[playerid][pTruckPct], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET MechanicPctSkill = '%d', ArmsPuncteSkill = '%d', Fireworks = '%d', PrisonTime = '%d, PrisonID = '%d', Newbie = '%d', NewbieMute = '%d WHERE ID = '%d'", playerVariables[playerid][pMechanicPctSkill], playerVariables[playerid][pArmsPuncteSkill], playerVariables[playerid][pFireworks], playerVariables[playerid][pPrisonTime], playerVariables[playerid][pPrisonID], playerVariables[playerid][pNewbie],
	playerVariables[playerid][pNewbieMute], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET CarKey1 = '%d', CarKey2 = '%d', CarKey3 = '%d', CarKey4 = '%d', CarKey5 = '%d', CarKey6 = '%d', CarKey7 = '%d', CarKey8 = '%d' CarKey9 = '%d', CarKey10 = '%d' WHERE ID = '%d'", playerVariables[playerid][pCarKey1], playerVariables[playerid][pCarKey2], playerVariables[playerid][pCarKey3], playerVariables[playerid][pCarKey4], playerVariables[playerid][pCarKey5], playerVariables[playerid][pCarKey6],
	playerVariables[playerid][pCarKey7], playerVariables[playerid][pCarKey8], playerVariables[playerid][pCarKey9], playerVariables[playerid][pCarKey10], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET FWarns = '%d', Hidden = '%d', FishTimes = '%d', FightStlye = '%d, PhoneBook = '%d', Hat = '%d', WKills = '%d', WDeaths = '%d', Gas = '%d', FarmTimes = '%d, FarmSkill = '%d' WHERE ID = '%d'", playerVariables[playerid][pFWarns], playerVariables[playerid][pHidden], playerVariables[playerid][pFishTimes], playerVariables[playerid][pFightStyle], playerVariables[playerid][pPhoneBook], playerVariables[playerid][pHat],
	playerVariables[playerid][pWKills], playerVariables[playerid][pWDeaths], playerVariables[playerid][pGas], playerVariables[playerid][pFarmTimes], playerVariables[playerid][pFarmSkill], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET Quest = '%d', QuestValue = '%d', QuestPrins = '%d', QuestPoint = '%d', SpecialSkin = '%d', QuestFinalizat = '%d', Quest2Value = '%d', Quest2 = '%d', Quest2Prins = '%d' WHERE ID = '%d'", playerVariables[playerid][pQuest], playerVariables[playerid][pQuestValue], playerVariables[playerid][pQuestPrins], playerVariables[playerid][pQuestPoint], playerVariables[playerid][pSpecialSkin], playerVariables[playerid][pQuestFinalizat],
	playerVariables[playerid][pQuest2Value], playerVariables[playerid][pQuest2], playerVariables[playerid][pQuest2Prins], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	format(szMessage, sizeof(szMessage), "UPDATE players SET Wanted = '%d', Phone = '%d', Banned = '%d', Realizari = '%d', Cash = '%d', Account = '%d' WHERE ID = '%d'", playerVariables[playerid][pWanted], playerVariables[playerid][pPhone], playerVariables[playerid][pBanned], playerVariables[playerid][pRealizari], playerVariables[playerid][pCash], playerVariables[playerid][pAccount], playerVariables[playerid][pID]);
	mysql_query(handle, szMessage);

	return 1;
}
stock NumberFormat(iNum, const szChar[] = ",")
{
    new szStr[16] ;

    format(szStr, sizeof(szStr), "%d", iNum);

    for(new iLen = strlen(szStr) - 3; iLen > 0; iLen -= 3)
    {
        strins(szStr, szChar, iLen);
    }
    return szStr;
}

stock PayDay()
{
	foreach(Player, x)
	{
	  	if(playerVariables[x][pStatus] == 1)
		{
  			GameTextForPlayer(x,"~g~PAYDAY", 5000, 1);

  			playerVariables[x][pRespectPoints] ++;

  			if(playerVariables[x][pFactionPunish] > 0) playerVariables[x][pFactionPunish] --;


			if(playerVariables[x][pSeconds] >= 1800)
			{
				playerVariables[x][pOreJucate] ++;
				
				if(playerVariables[x][pGiftHours] > 0)
				{
					playerVariables[x][pGiftHours] --;
				}
			}
			else
			{
  				new Float: mins;
				mins = playerVariables[x][pSeconds] / 60;

				if(playerVariables[x][pLimba] == 1)
				{
					format(szMessage, sizeof(szMessage), "Nu ai primit o ora completa pentru ca ai jucat doar %.0f minute (30 minute necesare pentru o ora jucata).", mins);
					S(x, COLOR_LIGHTBLUE, szMessage);
				}
				if(playerVariables[x][pLimba] == 2)
				{
					format(szMessage, sizeof(szMessage), "You didn't the get a full payday because you played only %.0f minutes (30 minutes needed for a full payday).", mins);
					S(x, COLOR_LIGHTBLUE, szMessage);
				}
				
			}

			new RandPay, TotalPay, Premium, BankInterest;
			
			if(playerVariables[x][pDonate] == 1)
			{
				BankInterest = playerVariables[x][pAccount];
				if(playerVariables[x][pSeconds] < 1800) playerVariables[x][pAccount] = floatround(playerVariables[x][pAccount]/2);
				RandPay = (playerVariables[x][pLevel] * 4000) + 2000 + random(5000);
				Premium = RandPay/3;
				TotalPay = playerVariables[x][pAccount] + RandPay + Premium;	
			}
			else
			{
				BankInterest = playerVariables[x][pAccount];
				if(playerVariables[x][pSeconds] < 1800) playerVariables[x][pAccount] = floatround(playerVariables[x][pAccount]/2);
				RandPay = (playerVariables[x][pLevel] * 4000) + 2000 + random(5000);
				TotalPay = playerVariables[x][pAccount] + RandPay;
			}


			format(szMessage, sizeof(szMessage), "Paycheck: $%s ", NumberFormat(RandPay));
			S(x, COLOR_GREY, szMessage);





			





      		if(playerVariables[x][pLicentaCondus] > 0)
			{
				new vehicleid = GetPlayerVehicleID(x);
				
				playerVariables[x][pLicentaCondus] --;
				
				if(playerVariables[x][pLicentaCondus] == 0)
				{
   					if(IsABike(vehicleid) || IsAPlane(vehicleid) || IsABoat(vehicleid))
	                {
	               
	                }
	                else
	                {
					    if(GetPlayerState(x) == PLAYER_STATE_DRIVER)
						{
		   					RemovePlayerFromVehicleEx(x);
						}
					}
					SS(x, COLOR_YELLOW, "* Licenta ta de condus a expirat. Pentru a o inrennoi, mergi la scoala de soferi.", "* Your driving license has expired. To renew it, go to driving school.");
				}
			}
			

   			if(playerVariables[x][pLicentaArme] > 0)
			{
				playerVariables[x][pLicentaArme] --;

				if(playerVariables[x][pLicentaArme] == 0)
				{
					SS(x, COLOR_YELLOW, "* Licenta ta de arme a expirat. Pentru a o inrennoi, contacteaza un instructor.", "* Your gun license has expired. To renew it, contact an instructor.");
				}
			}

   			if(playerVariables[x][pLicentaFly] > 0)
			{
				playerVariables[x][pLicentaFly] -= 1;
				if(playerVariables[x][pLicentaFly] == 0)
				{
					SS(x, COLOR_YELLOW, "* Licenta ta de pilotaj a expirat. Pentru a o inrennoi, contacteaza un instructor.", "* Your flying license has expired. To renew it, contact an instructor.");
				}
			}
   			if(playerVariables[x][pLicentaBoat] > 0)
			{
				playerVariables[x][pLicentaBoat] -= 1;
				if(playerVariables[x][pLicentaBoat] == 0)
				{
					SS(x, COLOR_YELLOW, "* Licenta ta de navigat a expirat. Pentru a o inrennoi, contacteaza un instructor.", "* Your sailing license has expired. To renew it, contact an instructor.");
				}
			}

			playerVariables[x][pSeconds] = 0;	
		 
  		}
  	}
  	return 1;
}	








