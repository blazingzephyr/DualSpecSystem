//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    X2SpecializationUtilities.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: Static functions reserved for working with the Specializations component.
//  Treated as a sort of 'manager' for them.
//
//----------------------------------------------------------------------------------------
class X2SpecializationUtilities extends Object config(DualSpecSystem) dependson(XComGameState_Unit_Specializations);

/*
 * Purpose: initialize XComGameState_Unit_Specializations for any given XComGameState_Unit.
 * Usage: virtually at any point in time.
 * 
 * If you are calling this from InstallNewCampaign, use the StartState parameter for NextState.
 * Otherwise, leave the NextState empty so the function uses XComGameStateContext_ChangeContainer itself.
 */
static function XComGameState_Unit_Specializations InitFor(XComGameState_Unit Soldier, optional XComGameState NextState = none)
{
    local XComGameState_Unit_Specializations    Specs;
    local X2GameRuleset                         GameRules;

    if (Soldier == none) return none;
    if (NextState == none) NextState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("X2_DSS_Init");

    Specs = XComGameState_Unit_Specializations(NextState.CreateNewStateObject(class'XComGameState_Unit_Specializations'));
    Specs.InitComponent();
    Soldier.AddComponentObject(Specs);
    
    GameRules = `GAMERULES;
    GameRules.SubmitGameState(NextState);

    return Specs;
}

/*
 * Purpose: returns the XComGameState_Unit_Specializations component of the given unit.
 * Usage: virtually at any point in time.
 * 
 * Creates the specialization component in case it wasn't for whatever reason.
 */
static function XComGameState_Unit_Specializations GetOrInit(XComGameState_Unit Soldier)
{
    local XComGameState_Unit_Specializations    Specs;
    if (Soldier == none) return none;

    Specs = XComGameState_Unit_Specializations(Soldier.FindComponentObject(class'XComGameState_Unit_Specializations'));
    if (Specs == none) Specs = InitFor(Soldier, none);
    else if (!Specs.IsInitialized) Specs.InitComponent();

    return Specs;
}

/*
 * Purpose: check whether the unit is still undergoing training.
 * Usage: specifically used in the UIScreenListener_SpecializationSystem.
 */
static function bool IsUndergoingTraining(XComGameState_Unit Soldier)
{
    local TrainingStatus    Status;
    Status = UpdateAndGetStatus(Soldier);

    return Status == eTrainingStatus_Ready || Status == eTrainingStatus_WeaponsAssigned;
}

/*
 * Purpose: update the unit and get its status.
 * Usage: used in the UIScreenListener_SpecializationSystem and other places.
 */
static function TrainingStatus UpdateAndGetStatus(XComGameState_Unit Soldier)
{
    local XComGameState_Unit_Specializations    Specs;
    Specs = GetOrInit(Soldier);

    if (Specs.Status == eTrainingStatus_Rookie && Soldier.GetRank() == 0 && Soldier.CanRankUpSoldier())
    {
        Specs.Status = eTrainingStatus_Ready;
    }

    return Specs.Status;
}
