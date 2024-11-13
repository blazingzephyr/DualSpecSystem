
//---------------------------------------------------------------------------------------
//  FILE:    UIScreenListener_SpecializationSystem.uc
//  AUTHOR:  blazingzephyr / DualSpecSystem --  09/11/2024
//  PURPOSE: Initializes the screen listener that activates the promotion windows.
//---------------------------------------------------------------------------------------
class UIScreenListener_SpecializationSystem extends UIScreenListener config(DualSpecSystem);

var UIArmory_MainMenu ParentScreen; /* The armory screen. */
var XComGameStateHistory History;
var XComGameState_Unit Unit;

var UIListItemString CMCListItem;
var string CMCListItemDescription;

var delegate<OnItemSelectedCallback> NextOnSelectionChanged;
delegate OnItemSelectedCallback(UIList _list, int itemIndex);

/*
 * Purpose: replaces 'Promote' button with 'Train Soldier' button in the armory. Acts as an entry point to the specialization system.
 * Runs: after a screen is initialized.
 */
event OnInit(UIScreen Screen)
{
    local UIArmory_MainMenu ArmoryScreen;
    local UIAfterAction PostMissionScreen;
    local UIPanel BG;
	local XComGameState_Unit_TrainingState TrainingState;
    
    ArmoryScreen = UIArmory_MainMenu(Screen);
    PostMissionScreen = UIAfterAction(Screen);
    History = `XCOMHISTORY;

    // Check whether the player is currently on the armory screen.
    if (ArmoryScreen != none)
    {
        // Add a reference to the viewed soldier.
		ParentScreen = UIArmory_MainMenu(Screen);
        Unit = XComGameState_Unit(History.GetGameStateForObjectID(ArmoryScreen.UnitReference.ObjectID));

		// Update mousewheel control to enable the list scrolling.
        if (ParentScreen != none)
        {
            BG = ParentScreen.Spawn(class'UIPanel', ParentScreen).InitPanel('armoryMenuBG');
            BG.bShouldPlayGenericUIAudioEvents = false;

            // Hook mousewheel to scroll MainMenu list instead of rotating the soldier.
            BG.ProcessMouseEvents(ParentScreen.List.OnChildMouseEvent);
        }

        // If the Rookie is ready to be promoted, create the 'Train Soldier' button.
		TrainingState = class'X2SpecializationUtilities'.static.GetOrInitSpecializations(Unit);
        if (TrainingState.IsUnitTraining())
        {
			NextOnSelectionChanged = ArmoryScreen.List.OnSelectionChanged;
			ArmoryScreen.List.OnSelectionChanged = OnSelectionChanged;

            // ArmoryScreen.List.OnSelectionChanged = OnSelectionChanged;
            Remove(ArmoryScreen);
        }
    }

    // Check whether the player is currently on the post-mission promotion screen with the soldiers walking out of the Skyranger.
    else if (PostMissionScreen != none)
    {
        A(PostMissionScreen);
        // DisablePromoteButtons(Screen); <-- ??? why
        //
        // Possibly disable the promote buttons for rookies, but enable the train soldier xd.
        // TBA logic
    }
}

simulated function A(UIAfterAction AfterActionScreen)
{/*
    // Index into the list of places where a soldier can stand in the after action scene, from left to right.
	local int SlotIndex;
	
	// Index into the HQ's squad array, containing references to unit state objects.		
	local int SquadIndex;

	// Index into the array of list items the player can interact with to view soldier status and promote.
	local int ListItemIndex;

	local UIAfterAction_ListItem ListItem;
	local UIList m_kSlotList;
	local XComGameState_Unit Unit;

	m_kSlotList = AfterActionScreen.m_kSlotList;

	ListItemIndex = 0;
	for (SlotIndex = 0; SlotIndex < AfterActionScreen.SlotListOrder.Length; ++SlotIndex)
	{
		SquadIndex = AfterActionScreen.SlotListOrder[SlotIndex];
		if (SquadIndex < AfterActionScreen.XComHQ.Squad.Length)
		{	
			if (AfterActionScreen.XComHQ.Squad[SquadIndex].ObjectID > 0)
			{
				Unit = XComGameState_Unit(History.GetGameStateForObjectID(AfterActionScreen.XComHQ.Squad[SquadIndex].ObjectID));
				if (Unit.GetRank() == 0 && Unit.CanRankUpSoldier() && Unit.isAlive())
				{
					if (m_kSlotList.itemCount > ListItemIndex)
					{
						ListItem = UIAfterAction_ListItem(m_kSlotList.GetItem(ListItemIndex));
						ListItem.PromoteButton.DisableButton();
					}
				}
				++ListItemIndex;
			}
		}
	}*/
}

event OnReceiveFocus(UIScreen Screen)
{    local UIArmory_MainMenu ArmoryScreen;
    local UIAfterAction PostMissionScreen;
    local UIPanel BG;
	local XComGameState_Unit_TrainingState TrainingState;

	local XComGameState_Unit Unit;
	local XComGameStateHistory History;

    ArmoryScreen = UIArmory_MainMenu(Screen);
    PostMissionScreen = UIAfterAction(Screen);
    History = `XCOMHISTORY;

    // Check whether the player is currently on the armory screen.
    if (ArmoryScreen != none)
    {
    	ParentScreen = UIArmory_MainMenu(Screen);
        // Add a reference to the viewed soldier.
        Unit = XComGameState_Unit(History.GetGameStateForObjectID(ParentScreen.UnitReference.ObjectID));

		if (Unit != none)
		{
			TrainingState = class'X2SpecializationUtilities'.static.GetOrInitSpecializations(Unit);
			if (TrainingState.IsUnitTraining())
			{
				// ArmoryScreen.List.OnSelectionChanged = OnSelectionChanged;
				Remove(ArmoryScreen);
			}
		}

        // If the Rookie is ready to be promoted, create the 'Train Soldier' button.
    }

    // Check whether the player is currently on the post-mission promotion screen with the soldiers walking out of the Skyranger.\
}


simulated function FindPromoteListItem(UIList List, out int ButtonIndex, out UIListItemString Item)
{
	local int Idx;
	local String PromoteIcon, strPromote;
	local UIListItemString Current;
	local XcomLWTuple Tuple;

	PromoteIcon="<img src='promote_icon' width='20' height='20'>";
	strPromote=PromoteIcon @ ParentScreen.m_strPromote;

	for (Idx = 0; Idx < List.ItemCount ; Idx++)
	{
		Current = UIListItemString(List.GetItem(Idx));
		//`log("Promote Search: Text=" $ Current.Text $ ", PromoteName=" $ strPromote);
		if (Current.Text == strPromote)
		{
			ButtonIndex = Idx;
			Item = Current;
		}
	}
}

simulated function Remove(UIArmory_MainMenu Screen)
{
    local int Idx;
	local String PromoteIcon, PromoteString;
	local UIListItemString Current;
    local String TrainSoldier;

	local UIListItemString NewList;
	local UIListItemString Promotebutton;
	local int Promotebuttonindex;

	FindPromoteListItem(Screen.List, Promotebuttonindex, Promotebutton);
	//Screen.List.MoveItemToBottom(Promotebutton);

	PromoteIcon="<img src='promote_icon' width='20' height='20'>";
	PromoteString=PromoteIcon @ "UHMMMMMM";

	//NewList = Promotebutton.InitListitem("");
	Promotebutton.SetText(PromoteString);
	Promotebutton.SetDisabled(false, "TBA Toolip");
	Promotebutton.ConfirmButton.OnClickedDelegate = OnChooseSpecsButtonCallback;
	Promotebutton.ConfirmButton.OnDoubleClickedDelegate = OnChooseSpecsButtonCallback;
	Promotebutton.buttonBG.OnClickedDelegate = OnChooseSpecsButtonCallback;
	CMCListItem = Promotebutton;

	//Screen.List.GetSelectedItem().OnLoseFocus();
	//Screen.List.SwapChildren(Screen.List.ItemCount - 1, Promotebuttonindex);
	//Screen.List.RealizeItems(0);
	//Screen.List.RealizeList();
	//Screen.List.GetSelectedItem().OnReceiveFocus();

	//Screen.Spawn(class'UiButton').InitButton('buttonXd', PromoteString, OnChooseSpecsButtonCallback, eUIButtonStyle_NONE, '');
	//Screen.List.AddChild();

	//Screen.List.AddChild();

	/*for (Idx = 0; Idx < Screen.List.ItemCount ; Idx++)
	{
		Current = UIListItemString(Screen.List.GetItem(Idx));
		if (Current.Text == PromoteString || Current.Text == Screen.m_strAbilities)
		{
            TrainSoldier = PromoteIcon @ CAPS("TBA Train");
            Current.SetText(TrainSoldier);
            Current.SetDisabled(false, "TBA TooltipText");
            Current.ButtonBG.OnClickedDelegate = OnChooseSpecsButtonCallback;
			CMCListItem = Current;
            break;
		}
	}*/
}

/*/
simulated function MoveItemToTop(UIList list, int Idx1, int Idx2)
{
	local int StartingIndex, ItemIndex;

	if(Idx1 != INDEX_NONE)
	{
		if(SelectedIndex > INDEX_NONE && SelectedIndex < ItemCount)
			GetSelectedItem().OnLoseFocus();

		ItemIndex = Idx1;
		while(ItemIndex > 0)
		{
			ItemContainer.SwapChildren(ItemIndex, ItemIndex - 1);
			ItemIndex--;
		}

		RealizeItems();

		if(SelectedIndex > INDEX_NONE && SelectedIndex < ItemCount)
			GetSelectedItem().OnReceiveFocus();
	}

	//if we move the currently selected item to the top, change the selection to the item that got moved into that location
	if(Idx1 == SelectedIndex && OnSelectionChanged != none)
		OnSelectionChanged(self, SelectedIndex);
}
*/

simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	if (ContainerList.GetItem(ItemIndex) == CMCListitem) 
	{
		ParentScreen.MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(CMCListItemDescription, true));
		return;
	}
	/*
	if (ContainerList.GetItem(ItemIndex) == CMCListitem) 
	{
		ParentScreen.MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(CMCListItemDescription, true));
		return;
	}
	if (ContainerList.GetItem(ItemIndex) == DismissListitem) 
	{
		ParentScreen.MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(ParentScreen.m_strDismissDesc, true));
		return;
	}*/

	NextOnSelectionChanged(ContainerList, ItemIndex);
}

event OnLoseFocus(UIScreen Screen);
event OnRemoved(UIScreen Screen)
{
	//clear reference to UIScreen so it can be garbage collected
	if(UIArmory_MainMenu(Screen) != none || UIAfterAction(Screen) != none)
		ParentScreen = none;
}


simulated function OnChooseSpecsButtonCallback(UIButton Button)
{
	local XComHQPresentationLayer HQPres;
	local UIChooseSpecializationScreen SpecScreen;
	local XComGameStateHistory History;

	History = History;
	HQPres = `HQPRES;
	SpecScreen = UIChooseSpecializationScreen(HQPres.ScreenStack.Push(HQPres.Spawn(class'UIChooseSpecializationScreen', HQPres), HQPres.Get3DMovie()));
	SpecScreen.ParentScreen = ParentScreen;
	SpecScreen.Unit = XComGameState_Unit(History.GetGameStateForObjectID(ParentScreen.UnitReference.ObjectID));
}

defaultproperties
{
	ScreenClass = none; //conditional filter in Event calls
}