//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    X2EventListener_SpecializationSystem.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: Contains hooks which trigger DualSpecSystem mod events.
//
//----------------------------------------------------------------------------------------
class X2EventListener_SpecializationSystem extends X2EventListener;

/*
 * Native accessor for CreateTemplates. Used by the engine object and template manager
 * to automatically pick up new templates.
 */
static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateListenerTemplates());

    return Templates;
}

/*
 * Creates the following event listeners (hooks) for this mod:
 * * AttachSpecializationComponent on NewCrewNotification
 */
static protected function CHEventListenerTemplate CreateListenerTemplates()
{
	local CHEventListenerTemplate   Template;
	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'DualSpecSystem_SoldierTrainingListener');

    Template.RegisterInTactical = false;
    Template.RegisterInStrategy = true;

    Template.AddCHEvent('NewCrewNotification', AttachSpecializationComponent, ELD_OnStateSubmitted);
    
	return Template;
}

/*
 * Purpose: initialize XComGameState_Unit_Specializations for the newly added soldiers.
 * Usage: on NewCrewNotification.
 */
static protected function EventListenerReturn AttachSpecializationComponent(
    Object EventData,
    Object EventSource,
    XComGameState GameState,
    Name Event,
    Object CallbackData)
{
    local XComGameState_Unit    UnitState;

    UnitState = XComGameState_Unit(EventData);
	class'X2SpecializationUtilities'.static.InitFor(UnitState);

    return ELR_NoInterrupt;
}
