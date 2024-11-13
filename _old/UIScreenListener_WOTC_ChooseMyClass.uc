
Class UIScreenListener_WOTC_ChooseMyClass extends UIScreenListener config(ChooseMyClass);


var config bool bHideArmoryPromoteRookieButton;
var config bool bDisableAfterActionPromoteRookieButton;


var UIArmory_MainMenu ParentScreen;
var UIListItemString CMCListItem;
var UIListItemString NewDismissListItem; // for replacing dismiss button to move to bottom of list
var UIListItemString DismissListItem;
var UIListItemString PromoteListItem;

var delegate<OnItemSelectedCallback> NextOnSelectionChanged;

var localized string strCMCMenuOption;
var localized string strCMCTooltip;
var string CMCListItemDescription;

delegate OnItemSelectedCallback(UIList _list, int itemIndex);


event OnInit(UIScreen Screen)
{
	local UIPanel BG;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;

	if(UIArmory_MainMenu(Screen) != none)
	{
		ParentScreen = UIArmory_Mainmenu(Screen); 

		History = `XCOMHISTORY;
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(ParentScreen.UnitReference.ObjectID));

		//update mousewheel controls so that mousewheel moves scrollbar when over list
		if(ParentScreen != none)
		{
				BG = ParentScreen.Spawn(class'UIPanel', ParentScreen).InitPanel('armoryMenuBG');
				BG.bShouldPlayGenericUIAudioEvents = false;  
				BG.ProcessMouseEvents(ParentScreen.List.OnChildMouseEvent); // hook mousewheel to scroll MainMenu list instead of rotating soldier
		}


		if (Unit.GetSoldierClassTemplate().DataName == 'Rookie' && Unit.CanRankUpSoldier())
		{
			NextOnSelectionChanged = ParentScreen.List.OnSelectionChanged;
			ParentScreen.List.OnSelectionChanged = OnSelectionChanged;

			InsertCMCListButton(Unit);
		}
	}

	/*if (UIAfterAction(Screen) != none && bDisableAfterActionPromoteRookieButton)
	{
		DisablePromoteButtons(Screen);
	}*/
}

event OnReceiveFocus(UIScreen Screen)
{
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;

	if(UIArmory_MainMenu(Screen) != none)
	{
		ParentScreen = UIArmory_Mainmenu(Screen);
		History = `XCOMHISTORY;
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(ParentScreen.UnitReference.ObjectID));


		if (Unit.GetSoldierClassTemplate().DataName == 'Rookie' && Unit.CanRankUpSoldier())
		{
			InsertCMCListButton(Unit);
		}
	}

	/*if(UIAfterAction(Screen) != none && bDisableAfterActionPromoteRookieButton)
	{
		DisablePromoteButtons(Screen);
	}*/
}


event OnLoseFocus(UIScreen Screen);
event OnRemoved(UIScreen Screen)
{
	//clear reference to UIScreen so it can be garbage collected
	if(UIArmory_MainMenu(Screen) != none || UIAfterAction(Screen) != none)
		ParentScreen = none;
}

simulated function InsertCMCListButton(XComGameState_Unit Unit)
{
	DismissListItem = FindDismissListItem(ParentScreen.List);
	DismissListItem.Hide(); // TODO: change this to remove if remove glitches for UIList is fixed
	AddListButton();
	CreateDismissButton(Unit);
	ParentScreen.List.MoveItemToBottom(DismissListItem);

	PromoteListItem = FindPromoteListItem(ParentScreen.List);
	if(bHideArmoryPromoteRookieButton)
	{
		PromoteListItem.Hide();
		ParentScreen.List.MoveItemToBottom(PromoteListItem);
}	}

//adds a button to the existing MainMenu list
simulated function AddListButton()
{
	local string PromoteIcon;

	CMCListItem = ParentScreen.Spawn(class'UIListItemString', ParentScreen.List.ItemContainer).InitListItem(Caps(strCMCMenuOption)).SetDisabled(false, strCMCTooltip);
	CMCListItem.ButtonBG.OnClickedDelegate = OnCMCButtonCallback;

	PromoteIcon = class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.HTML_PromotionIcon, 20, 20, 0) $ " ";
	CMCListItem.SetText(PromoteIcon $ Caps(strCMCMenuOption));
}

simulated function CreateDismissButton(XComGameState_Unit Unit)
{
	local bool bTutorialObjectInProgress, bInTutorialPromote, bUnitIsTraining, bCantDismiss;

	bInTutorialPromote = !class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory');
	bTutorialObjectInProgress = class'XComGameState_HeadquartersXCom'.static.AnyTutorialObjectivesInProgress();
	bUnitIsTraining = Unit.IsTraining() || Unit.IsPsiTraining() || Unit.IsPsiAbilityTraining();

	bCantDismiss = bInTutorialPromote || bTutorialObjectInProgress || bUnitIsTraining;

	NewDismissListItem = ParentScreen.Spawn(class'UIListItemString', ParentScreen.List.ItemContainer).InitListItem(ParentScreen.m_strDismiss).SetDisabled(bCantDismiss, strCMCTooltip);
	NewDismissListItem.ButtonBG.OnClickedDelegate = OnDismissButtonCallback;
}


simulated function OnCMCButtonCallback(UIButton kButton)
{
	local XComHQPresentationLayer HQPres;
	//local UIChooseClass_WOTC_ChooseMyClass ChooseClassScreen;
	local XcomGameState_Unit Unit;
	local XComGameStateHistory History;

	History = History;
	HQPres = `HQPRES;

	Unit = XComGameState_Unit(History.GetGameStateForObjectID(ParentScreen.UnitReference.ObjectID));
	//ChooseClassScreen = UIChooseClass_WOTC_ChooseMyClass(HQPres.ScreenStack.Push(HQPres.Spawn(class'UIChooseClass_WOTC_ChooseMyClass', HQPres), HQPres.Get3DMovie()));
	//ChooseClassScreen.ParentScreen=ParentScreen;
	//ChooseClassScreen.Unit=Unit;
}


//callback handler for list button -- invokes the base-game dismiss functionality
simulated function OnDismissButtonCallback(UIButton kButton)
{
	ParentScreen.OnDismissUnit();
}


simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	if (ContainerList.GetItem(ItemIndex) == CMCListitem) 
	{
		ParentScreen.MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(CMCListItemDescription, true));
		return;
	}
	if (ContainerList.GetItem(ItemIndex) == DismissListitem) 
	{
		ParentScreen.MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(ParentScreen.m_strDismissDesc, true));
		return;
	}
	NextOnSelectionChanged(ContainerList, ItemIndex);
}


simulated function UIListItemString FindDismissListItem(UIList List)
{
	local int Idx;
	local UIListItemString Current;

	for (Idx = 0; Idx < List.ItemCount ; Idx++)
	{
		Current = UIListItemString(List.GetItem(Idx));
		if (Current.Text == ParentScreen.m_strDismiss)
			return Current;
	}
	return none;
}


simulated function UIListItemString FindPromoteListItem(UIList List)
{
	local int Idx;
	local String PromoteIcon, strPromote;
	local UIListItemString Current;

	PromoteIcon="<img src='promote_icon' width='20' height='20'>";
	strPromote=PromoteIcon @ ParentScreen.m_strPromote;

	for (Idx = 0; Idx < List.ItemCount ; Idx++)
	{
		Current = UIListItemString(List.GetItem(Idx));
		//`log("Promote Search: Text=" $ Current.Text $ ", PromoteName=" $ strPromote);
		if (Current.Text == strPromote)
			return Current;
	}
	return none;
}



defaultproperties
{
	ScreenClass=none; //conditional filter in Event calls
}

/*
simulated function DisablePromoteButtons(UIScreen Screen)
{
	local int SlotIndex;		//Index into the list of places where a soldier can stand in the after action scene, from left to right
	local int SquadIndex;		//Index into the HQ's squad array, containing references to unit state objects
	local int ListItemIndex;	//Index into the array of list items the player can interact with to view soldier status and promote
	local UIAfterAction_ListItem ListItem;
	local UIList m_kSlotList;
	local UIAfterAction AfterActionScreen;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;

	AfterActionScreen = UIAfterAction(Screen);
	m_kSlotList = AfterActionScreen.m_kSlotList;
	History = `XCOMHISTORY;

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
}	}	}	}

*/