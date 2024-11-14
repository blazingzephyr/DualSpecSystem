
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
	class'X2SpecializationUtilities'.static.InitSpecsFor(UnitState);

    return ELR_NoInterrupt;
}
