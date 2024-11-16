//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    UIScreenListener_SoldierTrainingClosure.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: Temporary object used to store data and function used by OnClicked delegates.
//
//----------------------------------------------------------------------------------------
class UIScreenListener_SoldierTrainingClosure extends Object;

var UIScreen            	ParentScreen;	/* Screen which this was called from. */
var StateObjectReference	UnitReference;	/* Object reference to the promoted unit. */

/*
 * Purpose: Triggering the training screen.
 * Usage: OnTrainButtonClickedDelegate.
 */
simulated function OnTrainButtonCallback(UIButton Button)
{
	local XComHQPresentationLayer       HQPres;
	local UIChooseSpecializationScreen  SpecScreen;

	HQPres = `HQPRES;
	SpecScreen = HQPres.Spawn(class'UIChooseSpecializationScreen', HQPres);
    SpecScreen.ParentScreen = ParentScreen;
    SpecScreen.UnitReference = UnitReference;
    HQPres.ScreenStack.Push(SpecScreen, HQPres.Get3DMovie());
}
