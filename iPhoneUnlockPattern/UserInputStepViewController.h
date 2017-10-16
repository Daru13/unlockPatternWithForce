//
//  UserInputStepViewController.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "StepViewController.h"
#import "UserInputStepPatternView.h"
#import "UPFExperimentUser.h"
#import "UPFExperimentSession.h"

@interface UserInputStepViewController : StepViewController

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Specialization of the referenced, dynamicaly set pattern view's type
@property (weak, nonatomic) UserInputStepPatternView* embeddedPatternView;

// Related user handedness (may be related to the input mode)
@property (readonly) UPFUserMainHand mainHand;

// Main and secondary input modes (sub-steps)
@property (readonly) UPFSessionInputMode firstInputMode;
@property (readonly) UPFSessionInputMode secondInputMode;

// IB Outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoLastInputButton;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) initPropertiesWithDefaultValues;

- (void) updateCurrentSubstep;

- (void) nbUserInputsChanged;
- (void) userInputSetStateChanged;

- (IBAction)undoLastInputButtonPressed:(UIBarButtonItem *)sender;


@end
