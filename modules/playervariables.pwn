#include <a_samp>

enum playervEnum
{
	pPassword[128], pSeconds, pLevel, pOreJucate, pRobPoints, pCash, pReportDeelay, pFireworks, pPremiumPoints, pAccount, pDrugs, pEmail, pHelperLevel, pWarns, pDonate, pRegistred, pCheckpoint, pCredit, pTimerSellMats, pArmsPuncteSkill, pMaterials, pAreMats, pRespectPoints, pFactionPunish, pTimerSellGun, pFinalTutorial, pArmsDealerSkill, pLicentaArme, pBanned, pMatsTime, pColor, pTutorial, pSex, pLimba, pFishTimes, pAge, pGroup, pLicentaCondus, pAdminLevel, pJob, pGlasses, pSkin, pJobDelay,
	pFightStyle, pPhoneBook, pFood, pHat, pWKills, pWDeaths, pGas, pFarmTimes, pFarmSkill, pDeelayDice, pDuty, pDeelayDuty, pQuest, pQuestValue, pQuestPrins, pQuestPoint, pSpecialSkin, pQuestFinalizat, pQuest2, pQuest2Value, pQuest2Prins, pLive[128], pUsingDrugs, pAreDrugs, pDrugsTime, pLoginAttempts,
	pWanted, pSpamCount, pMuted, pFreezeTime, pFreezeType, pLicentaFly, pDeelayUseDrugs, pStuck, pPizzaPct, pLicentaBoat, pDeelayMechanic, pDeelayTransfer, pDeelayRefill, pDeelayRepair, pTimerSellDrugs, pMechanicSkill, pMechanicPctSkill, pDeelayPay, pReports, pPizzaSkill, pFish, pAlreadyFish, pFishSkill, pID, pCheckpointJob, pCheckpointPizza, pTruckSkill, pTruckPct, pGroupRank, pGroupDays, pGroupWarns, pAdminCover, pBusy, pDeelayHeal, pGiftHours, pFishPrice, pPrisonID, pPrisonTime, pFaina, pFarmTime,
	pConnected, pStatus, Float: pPos[3], pDeelayService, pNewbie, pNewbieMute, pNewName[MAX_PLAYER_NAME], pRealizari, pPhone, pCarKey1, pCarKey2, pCarKey3, pCarKey4, pCarKey5, pCarKey6, pCarKey7, pCarKey8, pCarKey9, pMP3, pCarKey10, pPhoneNumber, pPhoneStatus, pSleep, pSkinCount, pNextNotification, pBelt, pFWarns, pRequestName, pAdminDuty, pWalkieTalkie, pHidden, pVictim[64], pAccused[64], pRegDate[100], pCrime1[184], pCrime2[184], pCrime3[184], pQuestion[128], pOrganizator, pUsername[100], pLastLogin[100]
};
new szMessage[1000], handle;
new playerVariables[MAX_PLAYERS][playervEnum];
	

