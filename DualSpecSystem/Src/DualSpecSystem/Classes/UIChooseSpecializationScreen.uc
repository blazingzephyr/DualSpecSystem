
class UIChooseSpecializationScreen extends UIInventory config(SpecializationSystem);

var UIArmory_MainMenu ParentScreen;
var XComGameState_Unit Unit;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
    local XComGameState_Unit_TrainingState State;

	super.InitScreen(InitController, InitMovie, InitName);
    
    State = class'X2SpecializationUtilities'.static.GetOrInitSpecializations(Unit);
    State.TrainState = TrainingState_Finished;
    //Unit.Status.
}