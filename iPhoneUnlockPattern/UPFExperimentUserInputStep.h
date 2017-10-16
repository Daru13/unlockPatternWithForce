//
//  UPFExperimentUserInputStep.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 27/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPatternInputSet.h"

// Enumerated type for user input step states and sub-steps
typedef enum {
    USER_INPUT_STEP_STATE_DISPLAY_REFERENCE_PATH,
    USER_INPUT_STEP_STATE_FORCE_PROFILE_INPUT,
    USER_INPUT_STEP_STATE_TRAINING,
    USER_INPUT_STEP_STATE_USER_INPUTS
} UPFUserInputStepState;

typedef enum {
    USER_INPUT_SUBSTEP_NOT_STARTED,
    USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT,
    USER_INPUT_SUBSTEP_TWO_HANDS_INPUT,
    USER_INPUT_SUBSTEP_ENDED
} UPFUserInputSubstep;

@interface UPFExperimentUserInputStep : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Whole input containing the user-defined force profile; it may be nil is it has not been defined yet
// Note: the *path* also holds force information, as each path node contains the force it has been selected with
@property (copy) UPFPatternInputSet* forceProfileInputs;

// User inputs for both input modes (handedness)
@property (readonly) UPFPatternInputSet* singleHandInputSet;
@property (readonly) UPFPatternInputSet* twoHandsInputSet;

// Erroneous input sets, related to the three successful input sets above
@property (copy) UPFPatternInputSet* forceProfileErroneousInputs;
@property (copy) UPFPatternInputSet* singleHandErroneousInputs;
@property (copy) UPFPatternInputSet* twoHandsErroneousInputs;

@property (readonly) unsigned int requiredNbInputsWithSingleHand;
@property (readonly) unsigned int requiredNbInputsWithTwoHands;

// Current state and sub-step of the step
@property (readonly) UPFUserInputStepState state;
@property (readonly) UPFUserInputSubstep   substep;
@property (readonly) BOOL                  isFinished;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) startDisplayReferencePathMode;
- (void) startForceProfileInputMode;
- (void) startUserInputMode;

- (void) updateSubstepWith : (UPFUserInputSubstep) substep;
- (UPFPatternInputSet*) getInputSetRelatedToSubtep : (UPFUserInputSubstep) substep;
- (UPFPatternInputSet*) getInputSetRelatedToCurrentSubtep;
- (unsigned int) getNbRequiredInputsRelatedToSubstep : (UPFUserInputSubstep) substep;
- (unsigned int) getNbRequiredInputsRelatedToCurrentSubstep;

- (void) exportDataInFolderAtPath : (NSString*) path;

+ (UPFExperimentUserInputStep*) createUserInputStepRequiring : (unsigned int) requiredNbInputs;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
