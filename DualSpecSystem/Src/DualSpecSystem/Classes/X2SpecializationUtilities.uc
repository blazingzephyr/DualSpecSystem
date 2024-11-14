
class X2SpecializationUtilities extends Object config(DualSpecSystem);

static function XComGameState_Unit_TrainingState InitSpecsFor(XComGameState_Unit Unit, optional XcomGameState NextState = none)
{
    local XComGameState_Unit_TrainingState TrainingState;
    local X2GameRuleset GameRules;

    `log('Inializing train data for' @ Unit.GetFullName(),, 'Dual Specialization System');

    if (Unit == none) return none;
    if (NextState == none) NextState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("X2_DSC_Init");

    TrainingState = XComGameState_Unit_TrainingState(NextState.CreateNewStateObject(class'XComGameState_Unit_TrainingState'));
    TrainingState.TrainState = eTrainingState_Rookie;
    Unit.AddComponentObject(TrainingState);

    GameRules = `GAMERULES;
    GameRules.SubmitGameState(NextState);

    return TrainingState;
}

static function bool IsUnitTraining(XComGameState_Unit Unit)
{
    local XComGameState_Unit_TrainingState TrainState;

    if (Unit == none) return false;
    
    TrainState = XComGameState_Unit_TrainingState(Unit.FindComponentObject(class'XComGameState_Unit_TrainingState'));
    if (TrainState == none) TrainState = InitSpecsFor(Unit);
    if (TrainState.TrainState == eTrainingState_Rookie && Unit.GetRank() == 0 && Unit.CanRankUpSoldier())
    {
        TrainState.TrainState = eTrainingState_Ready;
    }

    return TrainState.TrainState == eTrainingState_Ready;
}
