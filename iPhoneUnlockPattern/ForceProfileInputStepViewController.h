//
//  ForceProfileInputViewController.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "StepViewController.h"
#import "ForceProfileInputStepPatternView.h"

@interface ForceProfileInputStepViewController : StepViewController

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Specialization of the referenced, dynamicaly set pattern view's type
@property (weak, nonatomic) ForceProfileInputStepPatternView* embeddedPatternView;

// Related user handedness (may be related to the input mode)
@property (readonly) UPFUserMainHand mainHand;

// Main input mode, used for the force profile input
@property (readonly) UPFSessionInputMode mainInputMode;

// IB Outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *continueToTrainingModeButton;


// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) nbForceProfileInputChanged;
- (void) forceProfileInputSetStateChanged;

@end
