
class XComGameState_Unit_TrainingState extends XComGameState_BaseObject config(DualSpecSystem);

enum TrainingState
{
    TrainingState_Rookie,
    TrainingState_InTraining,
    TrainingState_Finished
};

var XComGameState_Unit Soldier;
var TrainingState TrainState;

var bool IsTraining;

simulated function Initialize(XComGameState_Unit Unit)
{
    Soldier = Unit;
    TrainState = TrainingState_Rookie;
}

simulated function bool IsUnitTraining()
{
    if (TrainState == TrainingState_Rookie && Soldier.GetRank() == 0 && Soldier.CanRankUpSoldier())
    {
        TrainState = TrainingState_InTraining;
        //Soldier.SetStatus(eStatus_Training);
    }

    return TrainState == TrainingState_InTraining;
}