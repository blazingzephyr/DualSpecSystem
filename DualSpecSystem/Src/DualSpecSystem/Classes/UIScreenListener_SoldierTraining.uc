//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    UIScreenListener_SpecializationSystem.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: Initializes the screen listener that activates the promotion windows.
//
//----------------------------------------------------------------------------------------
class UIScreenListener_SoldierTraining extends UIScreenListener config(DualSpecSystem);

var localized string                    strTrainSoldier;            /* Train button text. */
var localized string                    strTrainSoldierTooltip;     /* Train button tooltip popup. */
var localized string                    strTrainSoldierDescription; /* Train button bottom description. */

var delegate<OnItemSelectedCallback>    NextOnSelectionChanged;     /* The original selection changed delegate. */
var UiPanel                             TrainButton;                /* The edited promotion button. */

delegate OnItemSelectedCallback(UIList _list, int itemIndex);

/*
 * Purpose: replaces 'Promote' button with 'Train Soldier' button in the armory. Acts as an entry point to the specialization system.
 * Runs: after a screen is initialized.
 */
event OnInit(UIScreen Screen)
{
    OnScreenDisplayed(Screen, true);
}

/*
 * Purpose: replaces 'Promote' button with 'Train Soldier' button in the armory. Acts as an entry point to the specialization system.
 * Runs: after a screen receives focus.
 */
event OnReceiveFocus(UIScreen Screen)
{
    OnScreenDisplayed(Screen);
}

event OnLoseFocus(UIScreen Screen);
event OnRemoved(UIScreen Screen);

/*
 * Purpose: trigger the soldier training screen if required.
 * Runs: after a screen is displayed / redisplayed.
 */
simulated function OnScreenDisplayed(UIScreen Screen, bool EnableScrolling = false)
{
    local XComGameStateHistory  History;
    local UIArmory_MainMenu     ArmoryScreen;
    local UIAfterAction         PostMissionScreen;
    local XComGameState_Unit    Unit;
    local UIPanel               BG;
    
    History = `XCOMHISTORY;
    ArmoryScreen = UIArmory_MainMenu(Screen);
    PostMissionScreen = UIAfterAction(Screen);

    if (ArmoryScreen != none)
    {
        // Add a reference to the viewed soldier.
        Unit = XComGameState_Unit(History.GetGameStateForObjectID(ArmoryScreen.UnitReference.ObjectID));

        if (EnableScrolling)
        {
            // Update mousewheel control to enable the list scrolling.
            BG = ArmoryScreen.Spawn(class'UIPanel', ArmoryScreen).InitPanel('armoryMenuBG');
            BG.bShouldPlayGenericUIAudioEvents = false;

            // Hook mousewheel to scroll MainMenu list instead of rotating the soldier.
            BG.ProcessMouseEvents(ArmoryScreen.List.OnChildMouseEvent);
        }
        
        // If the unit is 'none', this will not work either way.
        // Otherwise, if the unit is a Rookie or being trained, update the buttons.
        if(class'X2SpecializationUtilities'.static.IsUndergoingTraining(Unit))
        {
            if (EnableScrolling)
            {
                NextOnSelectionChanged = ArmoryScreen.List.OnSelectionChanged;
                ArmoryScreen.List.OnSelectionChanged = OnSelectionChanged;
            }

            ReplacePromotionInArmory(ArmoryScreen);
        }
    }

    // On the post mission, replace the promotion buttons with train soldier buttons.
    if (PostMissionScreen != none)
    {
        ReplacePromotionOnResultsScreen(PostMissionScreen);
    }
}

/*
 * Purpose: displays tooltip.
 * Runs: whenever the user hovers over a control.
 */
simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
    local UIMCController MC;
	if (ContainerList.GetItem(ItemIndex) == TrainButton)
    {
		MC = TrainButton.Screen.MC;
        MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(strTrainSoldierDescription, true));
		return;
    }

	NextOnSelectionChanged(ContainerList, ItemIndex);
}

/*
 * Purpose: replaces the promotion button in the Armory and changes its behavior.
 * Runs: after a unit is viewed in the Armory.
 */
simulated function ReplacePromotionInArmory(UIArmory_MainMenu Screen)
{
    local String                                    PromoteIcon;
    local UIListItemString                          PromoteButton;
    local UIScreenListener_SoldierTrainingClosure   Closure;

	Closure = new class'UIScreenListener_SoldierTrainingClosure';
    Closure.ParentScreen = Screen;
	Closure.UnitReference = Screen.UnitReference;

	PromoteIcon="<img src='promote_icon' width='20' height='20'>";
    PromoteButton = FindPromoteListItem(Screen);
    PromoteButton.SetText(PromoteIcon @ strTrainSoldier);
	PromoteButton.SetDisabled(false, strTrainSoldierTooltip);

	PromoteButton.ConfirmButton.OnClickedDelegate = Closure.OnTrainButtonCallback;
	PromoteButton.ConfirmButton.OnDoubleClickedDelegate = Closure.OnTrainButtonCallback;
	PromoteButton.buttonBG.OnClickedDelegate = Closure.OnTrainButtonCallback;
	TrainButton = PromoteButton;
}

/*
 * Purpose: Finds the promotion button in the Armory.
 */
simulated function UIListItemString FindPromoteListItem(UIArmory_MainMenu Screen)
{
	local int               Idx;
	local String            PromoteIcon, PromotionString;
    local UIList            List;
	local UIListItemString  Current;

	PromoteIcon = "<img src='promote_icon' width='20' height='20'>";
	PromotionString = PromoteIcon @ Screen.m_strPromote;
    List = Screen.List;

	for (Idx = 0; Idx < List.ItemCount ; Idx++)
	{
		Current = UIListItemString(List.GetItem(Idx));
		if (Current.Text == PromotionString) return Current;
	}
}

/*
 * Purpose: links the promotion button on the Avenger post-mission screen to trigger soldier training.
 * Runs: after a mission is completed.
 */
simulated function ReplacePromotionOnResultsScreen(UIAfterAction Screen)
{
	local XComGameStateHistory                      History;
    // local String                                 PromoteIcon;
	local UIList                                    m_kSlotList;
	local int                                       SlotIndex;
    local int                                       SquadIndex;
    local array<StateObjectReference>               Squad;
    local XComGameState_Unit                        Unit;
    local UIButton                                  PromoteButton;
    local UIAfterAction_ListItem                    ListItem;
    local int                                       ListItemIndex;
    local UIScreenListener_SoldierTrainingClosure   Closure;

    History = `XCOMHISTORY;
    // PromoteIcon="<img src='promote_icon' width='20' height='20'>";
    m_kSlotList = Screen.m_kSlotList;
	ListItemIndex = 0;

    for (SlotIndex = 0; SlotIndex < Screen.SlotListOrder.Length; ++SlotIndex)
    {
		SquadIndex = Screen.SlotListOrder[SlotIndex];
        Squad = Screen.XComHQ.Squad;

		if (SquadIndex < Squad.Length)
        {
            Unit = XComGameState_Unit(History.GetGameStateForObjectID(Squad[SquadIndex].ObjectID));
            if (class'X2SpecializationUtilities'.static.IsUndergoingTraining(Unit))
            {
	            Closure = new class'UIScreenListener_SoldierTrainingClosure';
                Closure.ParentScreen = Screen;
	            Closure.UnitReference = Unit.GetReference();

				ListItem = UIAfterAction_ListItem(m_kSlotList.GetItem(ListItemIndex));
                PromoteButton = ListItem.PromoteButton;
                PromoteButton.OnClickedDelegate = Closure.OnTrainButtonCallback;
                TrainButton = PromoteButton;

                // Known issue #1: Renaming the button directly doesn't work as it does not have any text of its own.
                // However, the button still works as it is linked to the callback.
                //
                // PromoteButton.SetText(PromoteIcon @ strTrainSoldier);
                // PromoteButton.SetDisabled(false, strTrainSoldierTooltip);
            }

            if (Unit != none) ++ListItemIndex;
        }
    }
}

defaultproperties
{
	ScreenClass = none; /* conditional filter in Event calls */
}
