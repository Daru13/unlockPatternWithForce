//
//  UserInputStepPatternView.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 03/07/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "PatternView.h"
@class UserInputStepViewController;

@interface UserInputStepPatternView : PatternView

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Reference to the parent view's controller
@property UserInputStepViewController* parentViewController;

// Reference to the current input set to use
// Note: those patterns must have a path similar to the view's pattern path, i.e. to the current reference path
@property (readonly) UPFPatternInputSet* userInputs;

// Set of erroneous user inputs; they are only saved for gathering more data during the experiment
@property (readonly) UPFPatternInputSet* erroneousUserInputs;

// Current + required number of valid inputs to consider the set full
@property (readonly) unsigned int nbUserInputs;
@property            unsigned int requiredNbUserInputs;

// Indicates a valid input set is full when set to YES
@property (readonly) BOOL userInputSetIsFull;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) resetUserInputsWith : (UPFPatternInputSet*) inputSet
                             : (unsigned int) nbRequiredInputs;
- (void) addInput : (UPFPatternInput*) input;
- (BOOL) lastSavedInputCanBeCanceled;
- (void) cancelLastSavedInput;

@end
