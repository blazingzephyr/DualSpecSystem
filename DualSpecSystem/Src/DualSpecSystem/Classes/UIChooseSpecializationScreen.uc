//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    UIChooseSpecializationScreen.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: The classes commodity screen. Implements classes selection logic.
//
//----------------------------------------------------------------------------------------
class UIChooseSpecializationScreen extends UISimpleCommodityScreen config(DualSpecSystem);

var UIScreen            	ParentScreen;	/* Screen which this was called from. */
var StateObjectReference	UnitReference;	/* Object reference to the promoted unit. */

defaultproperties
{
	DisplayTag="UIBlueprint_Promotion"
	CameraTag="UIBlueprint_Promotion"
	InputState = eInputState_Consume;
	bHideOnLoseFocus = true;
	bConsumeMouseEvents = true;
}
