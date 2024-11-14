
class XComGameState_Unit_TrainingState extends XComGameState_BaseObject config(DualSpecSystem);

enum TrainingState
{
    eTrainingState_Rookie,
    eTrainingState_Ready,
    eTrainingState_Finished
};

var XComGameState_Unit Soldier;
var TrainingState TrainState;
var bool IsTraining;
