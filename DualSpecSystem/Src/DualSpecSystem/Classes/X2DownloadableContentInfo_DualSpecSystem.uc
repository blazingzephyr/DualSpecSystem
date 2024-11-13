//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_DualSpecSystem.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2DownloadableContentInfo_DualSpecSystem extends X2DownloadableContentInfo config(DualSpecSystem);

var config array<name> RemoveGuerillaUpgrades;  /* Guerilla Tactics School class upgrades to remove. */


/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{	
	ModifyAllSoldiersInBarracks(StartState);
}

static function ModifyAllSoldiersInBarracks(XComGameState StartState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Unit UnitState;
	local XComGameState_Unit_TrainingState TrainingState;

    local XComGameState_BaseObject B;

	History = `XCOMHISTORY;

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	Soldiers = XComHQ.GetSoldiers();

	foreach Soldiers(UnitState)
	{
        `LOG("[A] Creating specializations component for " $ UnitState.GetFullName(),, 'Liberators Specialization System');
        // Buggy
        TrainingState = XComGameState_Unit_TrainingState(StartState.CreateNewStateObject(class'XComGameState_Unit_TrainingState'));
        TrainingState.Initialize(UnitState);

        StartState.AddStateObject(UnitState);
        StartState.AddStateObject(TrainingState);
	}
}

/*
 * Purpose: removes class squad upgrades from Guerilla Tactics School.
 * Runs: after all mod templates are created.
 */
static event OnPostTemplatesCreated()
{
    local X2StrategyElementTemplateManager Manager;
    local array<X2DataTemplate> DataTemplates;
    local X2DataTemplate DataTemplate;
    local X2FacilityTemplate FacilityTemplate;
    local name GuerillaTemplate;

    // Find Guerilla Tactics School templates.
    Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
    Manager.FindDataTemplateAllDifficulties('OfficerTrainingSchool', DataTemplates);

    // Remove each class upgrade entry from each data template.
    foreach DataTemplates(DataTemplate)
    {
        FacilityTemplate = X2FacilityTemplate(DataTemplate);
        if (FacilityTemplate != none)
        {
            foreach default.RemoveGuerillaUpgrades(GuerillaTemplate)
            {
                FacilityTemplate.SoldierUnlockTemplates.RemoveItem(GuerillaTemplate);
            }
        }
    }
}
