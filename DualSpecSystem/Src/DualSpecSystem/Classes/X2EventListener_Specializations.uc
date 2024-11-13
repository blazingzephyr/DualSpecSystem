
class X2EventListener_Specializations extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateListenerTemplates());

    return Templates;
}

static protected function CHEventListenerTemplate CreateListenerTemplates()
{
	local CHEventListenerTemplate Template;
    local X2EventManager m;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'DualSpecSystem_SpecializationListener');

    //.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

    
	//Template.AddCHEvent('SoldierTacticalToStrategy', SoldierTacticalToStrategy_CheckStartedTired, ELD_OnStateSubmitted, 99);

	//`XEVENTMGR.RegisterForEvent(SelfObject, 'NewCrewNotification', NewCrewAdded, ELD_OnStateSubmitted);
// UnitRandomizedStats
	// Probably works but activates only for NEW members?
	Template.AddCHEvent('NewCrewNotification', AttachSpecializationComponent, ELD_OnStateSubmitted);

	//Template.AddCHEvent('OverrideLocalizedAbilityTreeTitle', PassSpecializationName, ELD_Immediate, 50);

	//Template.AddCHEvent('SoldierClassIcon', OnSoldierInfo, ELD_Immediate);
	//Template.AddCHEvent('SoldierClassDisplayName', OnSoldierInfo, ELD_Immediate);
	//Template.AddCHEvent('SoldierClassSummary', OnSoldierInfo, ELD_Immediate);

	return Template;
}

/*


function EventListenerReturn NewCrewAdded(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit CrewUnit;

	CrewUnit = XComGameState_Unit(EventData);
	if (CrewUnit != None)
		NewCrewMembers.AddItem(CrewUnit.GetReference());

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn SoldierTacticalToStrategy_CheckStartedTired (Object EventData, Object EventSource, XComGameState EventGameState, Name Event, Object CallbackData)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_Unit UnitState, PrevUnitState;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local int MaxWill, MinWill, Roll, Diff, HalfDiff;
	local array<name> ValidTraits, GenericTraits;
	local bool bAddTrait;
	local name TraitName;

	if (!default.MindShieldOnTiredNerf_Enabled[`StrategyDifficultySetting])
	{
		return ELR_NoInterrupt;
	}

	UnitState = XComGameState_Unit(EventSource);
	if (UnitState == none) return ELR_NoInterrupt;

	// Make sure the unit fully came back to avenger
	// Since we are in ELD_OSS, this will take care of things like death and capture (see XCGSC_SGR)
	if (`XCOMHQ.Crew.Find('ObjectID', UnitState.ObjectID) == INDEX_NONE)
	{
		`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": unit" @ UnitState.ObjectID @ "is not part of HQ crew, skipping");
		return ELR_NoInterrupt;
	}

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	History = `XCOMHISTORY;

	if (CIInfo.UnitsStartedMissionBelowReadyWill.Find('ObjectID', UnitState.ObjectID) == INDEX_NONE)
	{
		`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": unit" @ UnitState.ObjectID @ "did not start mission below ready will, skipping");
		return ELR_NoInterrupt;
	}

	if (!UnitHasMindshieldNerfItem(UnitState.GetReference()))
	{
		`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": unit" @ UnitState.ObjectID @ "started below ready will but has no mindshield item, skipping");
		return ELR_NoInterrupt;
	}

	`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": applying penalty to unit" @ UnitState.ObjectID);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Applying tired mindshield penatly to unit" @ UnitState.ObjectID);
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

	// Part 1 - set unit to shaken if not shaken already
	if (UnitState.GetMentalState() == eMentalState_Shaken)
	{
		`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": unit" @ UnitState.ObjectID @ "is already shaken");
	}
	else
	{
		MaxWill = UnitState.GetMaxWillForMentalState(eMentalState_Shaken);
		MinWill = UnitState.GetMinWillForMentalState(eMentalState_Shaken);

		Diff = MaxWill - MinWill;
		HalfDiff = Diff / 2; // int division is correct here

		Roll = `SYNC_RAND_STATIC(HalfDiff);

		UnitState.SetCurrentStat(eStat_Will, MinWill + HalfDiff + Roll);
		UnitState.UpdateMentalState();

		`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": set unit" @ UnitState.ObjectID @ "to shaken");
		`CI_Trace(`showvar(MinWill));
		`CI_Trace(`showvar(MaxWill));
		`CI_Trace(`showvar(Diff));
		`CI_Trace(`showvar(HalfDiff));
		`CI_Trace(`showvar(Roll));
	}

	// Part 2 - add a negative trait
	bAddTrait = true;

	if (!default.MindShieldOnTiredNerf_PermitTraitStacking)
	{
		// Get the unit state from before SquadTacticalToStrategyTransfer was applied to it
		PrevUnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitState.ObjectID,, EventGameState.HistoryIndex - 1));

		if (UnitState.NegativeTraits.Length > PrevUnitState.NegativeTraits.Length)
		{
			bAddTrait = false;
			`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": unit" @ UnitState.ObjectID @ "already got a negative trait from this mission");
		}
	}

	if (bAddTrait)
	{
		GenericTraits = class'X2TraitTemplate'.static.GetAllGenericTraitNames();

		foreach GenericTraits(TraitName)
		{
			if (UnitState.AcquiredTraits.Find(TraitName) == INDEX_NONE && UnitState.PendingTraits.Find(TraitName) == INDEX_NONE)
			{
				`AddUniqueItemToArray(ValidTraits, TraitName);
			}
		}

		if (ValidTraits.Length < 1)
		{
			`RedScreen(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": found no valid traits for unit" @ UnitState.ObjectID);
		}
		else
		{
			TraitName = ValidTraits[`SYNC_RAND_STATIC(ValidTraits.Length)];

			UnitState.AddAcquiredTrait(NewGameState, TraitName);
			`CI_Trace(nameof(SoldierTacticalToStrategy_CheckStartedTired) $ ": unit" @ UnitState.ObjectID @ "got trait" @ TraitName);
		}
	}

	`SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}
 */

static protected function EventListenerReturn AttachSpecializationComponent(
    Object EventData,
    Object EventSource,
    XComGameState GameState,
    Name Event,
    Object CallbackData)
{
    local XComGameState_Unit UnitState;
    local XComGameState NewState;
    local XComGameState_Unit_TrainingState TrainingState;
    local X2GameRuleset GameRules;

    UnitState = XComGameState_Unit(EventData);
    if (UnitState != none)
    {
		class'X2SpecializationUtilities'.static.InitSpecializations(UnitState);
    }

    return ELR_NoInterrupt;
}
