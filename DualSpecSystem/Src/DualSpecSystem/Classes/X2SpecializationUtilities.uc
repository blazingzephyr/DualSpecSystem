
class X2SpecializationUtilities extends Object config(DualSpecSystem);

/*
 *
 */
static function XComGameState_Unit_TrainingState GetOrInitSpecializations(XComGameState_Unit Unit)
{
    local XComGameState_BaseObject Component;
    local XComGameStateHistory History;

    if (Unit != none)
    {
        History = `XCOMHISTORY;
        Component = Unit.FindComponentObject(class'XComGameState_Unit_TrainingState');
        if (Component == none)
        {
            return InitSpecializations(Unit);
        }

        return XComGameState_Unit_TrainingState(Component);
    }
    
    return none;
}

/*
 *
 */
static function XComGameState_Unit_TrainingState InitSpecializations(XComGameState_Unit Unit)
{
    local XComGameState                     NewState;
    local XComGameState_Unit_TrainingState  TrainingState;
    local X2GameRuleset                     GameRules;

	`LOG("Creating specializations component for " $ Unit.GetFullName(),, 'Liberators Specialization System');
    NewState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Attempting to initialize specializations...");
    TrainingState = XComGameState_Unit_TrainingState(NewState.CreateNewStateObject(class'XComGameState_Unit_TrainingState'));
    TrainingState.Initialize(Unit);

    GameRules = `GAMERULES;
    GameRules.SubmitGameState(NewState);

    return TrainingState;
}
