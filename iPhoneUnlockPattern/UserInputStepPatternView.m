//
//  UserInputStepPatternView.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 03/07/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UserInputStepPatternView.h"
#import "UserInputStepViewController.h"
#import "UPFPatternInputSet.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UserInputStepPatternView ()

@property (readwrite) UPFPatternInputSet* userInputs;
@property (readwrite) UPFPatternInputSet* erroneousUserInputs;

@property (readwrite) unsigned int nbUserInputs;

@property (readwrite) BOOL userInputSetIsFull;

// Internal counter to avoid multiple undos
@property unsigned int nbAddedInputsSinceLastInputCancel;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UserInputStepPatternView

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

// Override to initialize additional properties
- (void) initPropertiesWithDefaultValues {
    // Initialize all regular properties
    [super initPropertiesWithDefaultValues];
    
    // Default init of additional properties
    [self resetUserInputsWith : nil : 0];
    self.nbAddedInputsSinceLastInputCancel = 0;
}

// --------------------------------------------------------------
// USER INPUTS
// --------------------------------------------------------------

// This method must be called once at the beginning of every substep
- (void) resetUserInputsWith : (UPFPatternInputSet*) inputSet
                             : (unsigned int) nbRequiredInputs {
    self.userInputs          = inputSet;
    self.erroneousUserInputs = [UPFPatternInputSet createEmptyInputSetOfSize : INPUT_SET_UNLIMITED_INPUTS
                                                           checkPathMatching : NO];
    
    self.nbUserInputs         = 0;
    self.requiredNbUserInputs = nbRequiredInputs;
    self.userInputSetIsFull   = NO;
    
    self.nbAddedInputsSinceLastInputCancel = 0;
}

- (void) addInput : (UPFPatternInput*) input {
    [self.userInputs addInput : input];
    self.nbUserInputs++;
    self.nbAddedInputsSinceLastInputCancel++;
    
    [self.parentViewController nbUserInputsChanged];
    
    // Check whether the required number of inputs has been reached or not
    if (self.nbUserInputs == self.requiredNbUserInputs) {
        self.userInputSetIsFull = YES;
        [self.parentViewController userInputSetStateChanged];
    }
}

// Return YES if the last saved input (if any) can be canceled; NO otherwise
- (BOOL) lastSavedInputCanBeCanceled {
    return self.nbAddedInputsSinceLastInputCancel > 0
        && self.nbUserInputs > 0;
}

// This method may be called in case of undo
// If cancelation is not available, nothing happens
- (void) cancelLastSavedInput {
    if (! [self lastSavedInputCanBeCanceled])
        return;
    
    [self.userInputs removeLastInput];
    self.nbUserInputs--;
    self.nbAddedInputsSinceLastInputCancel = 0;
    
    [self.parentViewController nbUserInputsChanged];
    
    // If it was the last required input, the set is not full anymore
    if (self.nbUserInputs == self.requiredNbUserInputs - 1) {
        self.userInputSetIsFull = NO;
        [self.parentViewController userInputSetStateChanged];
    }
}

- (void) addErroneousInput : (UPFPatternInput*) erroneousInput {
    [self.erroneousUserInputs addInput : erroneousInput];
}

// --------------------------------------------------------------
// REGULAR MULTITOUCH EVENTS PROCESSING
// --------------------------------------------------------------

// TODO: notify the parent view's controller in another, better way

- (void) onTouchEnded {
    // Make sure a reference path is defined; otherwise, simply clear the current input
    if ((! [self.pattern referenceInputSetIsDefined])
        ||  self.pattern.referenceInputSet.nbInputs == 0) {
        NSLog(@"Warning: no reference input is defined in the user input step pattern view, which is abnormal!");
        
        [self handleErroneousUserInput];
        return;
    }
    
    // Save the current input if its path matches with the reference path
    if ([self.pattern matchesWithInput : self.userInput]) {
        [self addInput : self.userInput];
        [self.userInput clear];
    }
    else {
        [self addErroneousInput : self.userInput];
        [self handleErroneousUserInput];
    }
    
}


@end
