//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    XComGameState_Unit_Specializations.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: Component object encapsulating Unit's specialization details.
//
//----------------------------------------------------------------------------------------
class XComGameState_Unit_Specializations extends XComGameState_BaseObject;

//----------------------------------------------------------------------------------------
//  *********   DUAL SPEC SYSTEM SOURCE CODE   *********
//  FILE:    XComGameState_Unit_Specializations.uc
//  AUTHOR:  blazingzephyr
//
//  PURPOSE: Soldier's in-game specialization acquisition status.
//
//----------------------------------------------------------------------------------------
enum TrainingStatus
{
    eTrainingStatus_None,
    eTrainingStatus_Rookie,
    eTrainingStatus_Ready,
    eTrainingStatus_WeaponsAssigned,
    eTrainingStatus_RolesAssigned
};

var bool            IsInitialized;  /* Determines whether this component was initialized with InitComponent. */
var TrainingStatus  Status;         /* Soldier's specialization training status. */

/*
 * Purpose: set the initial component information.
 * Usage: whenever you create this component using any means (game state, etc.)
 */
simulated function InitComponent()
{
    IsInitialized = true;
    Status = eTrainingStatus_Rookie;
}

defaultproperties
{
    IsInitialized = false;
    Status = eTrainingStatus_None;
}
