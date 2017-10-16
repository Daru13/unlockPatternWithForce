//
//  ForceProfileInputStepPatternView.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "PatternView.h"
#import "UPFPatternInputSet.h"
@class ForceProfileInputStepViewController;

@interface ForceProfileInputStepPatternView : PatternView

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Reference to the parent view's controller
@property ForceProfileInputStepViewController* parentViewController;

// Set of user inputs, saved for the force profile(s)
// Note: those patterns must have a path similar to the view's pattern path, i.e. to the current reference path
@property (readonly) UPFPatternInputSet* forceProfileUserInputs;

// Set of erroneous user inputs; they are only saved for gathering more data during the experiment
@property (readonly) UPFPatternInputSet* erroneousUserInputs;

// Current + required number of valid inputs to consider the force profile fully set
@property (readonly) unsigned int nbForceProfileInputs;
@property (readonly) unsigned int requiredNbForceProfileInputs;

// Indicates a valid force profile is fully set when set to YES
@property (readonly) BOOL forceProfileIsFullySet;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) initPropertiesWithDefaultValues;

@end
