//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    X2DownloadableContentInfo_DualSpecSystem.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: Use the X2DownloadableContentInfo class to specify unique mod behavior
//  when the player creates a new campaign or loads a saved game.
//
//----------------------------------------------------------------------------------------
class X2DownloadableContentInfo_DualSpecSystem extends X2DownloadableContentInfo config(DualSpecSystem);

var config array<name> RemoveGuerillaUpgrades;  /* Guerilla Tactics School class upgrades to remove. */

/*
 * Called when the player starts a new campaign while this DLC / Mod is installed
 */
static event InstallNewCampaign(XComGameState StartState)
{
    ModifySoldiersInBarracks(StartState);
}

/*
 * Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
 */
static event OnPostTemplatesCreated()
{
    RemoveClassUpgrades();
}

/*
 * Purpose: initializes Dual Spec System hooks for the initial roster.
 * Runs: after a new campaign is started.
 */
static function ModifySoldiersInBarracks(XComGameState StartState)
{
    local XComGameStateHistory              History;
    local XComGameState_HeadquartersXCom    XComHQ;
	local array<XComGameState_Unit>         Soldiers;
	local XComGameState_Unit                Soldier;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
    Soldiers = XComHQ.GetSoldiers();

    foreach Soldiers(Soldier)
    {
        // Specify the NextStart or the game state initialization will fail!
        class'X2SpecializationUtilities'.static.InitFor(Soldier, StartState);
    }
}

/*
 * Purpose: removes class squad upgrades from Guerilla Tactics School.
 * Runs: after all mod templates are created.
 */
static function RemoveClassUpgrades()
{
    local X2StrategyElementTemplateManager  Manager;
    local array<X2DataTemplate>             DataTemplates;
    local X2DataTemplate                    DataTemplate;
    local X2FacilityTemplate                FacilityTemplate;
    local name                              GuerillaTemplate;

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
