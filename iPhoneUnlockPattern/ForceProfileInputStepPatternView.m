//
//  ForceProfileInputStepPatternView.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFExperimentConstants.h"
#import "ForceProfileInputStepPatternView.h"
#import "ForceProfileInputStepViewController.h"
#import "UPFPatternInputSet.h"

// ----------------------------------------------------------------- Internal interface ---

@interface ForceProfileInputStepPatternView ()

@property (readwrite) UPFPatternInputSet* forceProfileUserInputs;
@property (readwrite) UPFPatternInputSet* erroneousUserInputs;

@property (readwrite) unsigned int nbForceProfileInputs;
@property (readwrite) unsigned int requiredNbForceProfileInputs;

@property (readwrite) BOOL forceProfileIsFullySet;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation ForceProfileInputStepPatternView 

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

// Override to initialize additional properties
- (void) initPropertiesWithDefaultValues {
    // Initialize all regular properties
    [super initPropertiesWithDefaultValues];
    
    [self resetUserInputsWith : [UPFPatternInputSet createEmptyInputSetOfSize : EXPERIMENT_NB_FORCE_PROFILE_INPUTS]
                                                                              : EXPERIMENT_NB_FORCE_PROFILE_INPUTS];
}

// --------------------------------------------------------------
// USER INPUTS
// --------------------------------------------------------------

- (void) resetUserInputsWith : (UPFPatternInputSet*) inputSet
                             : (unsigned int) nbRequiredInputs {
    self.forceProfileUserInputs = inputSet;
    self.erroneousUserInputs    = [UPFPatternInputSet createEmptyInputSetOfSize : INPUT_SET_UNLIMITED_INPUTS
                                                           checkPathMatching : NO];
    
    self.nbForceProfileInputs         = 0;
    self.requiredNbForceProfileInputs = nbRequiredInputs;
    self.forceProfileIsFullySet       = NO;
}

- (void) addInput : (UPFPatternInput*) input {
    [self.forceProfileUserInputs addInput : input];
    self.nbForceProfileInputs++;
    
    [self.parentViewController nbForceProfileInputChanged];
    
    // Check whether the required number of inputs has been reached or not
    if (self.nbForceProfileInputs == self.requiredNbForceProfileInputs) {
        self.forceProfileIsFullySet = YES;
        [self.parentViewController forceProfileInputSetStateChanged];
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
        [self.userInput clear];
        return;
    }
    
    // Check if user input matches the reference path...
    if ([self.pattern matchesWithInput : self.userInput]) {
        // Update the force profile input set with the current user input
        NSLog(@"Adding current input (%@) to force profile input set (%@)", self.userInput, self.forceProfileUserInputs);
        
        [self.forceProfileUserInputs addInput : self.userInput];
        self.nbForceProfileInputs++;
        
        [self.parentViewController nbForceProfileInputChanged];
        
        // Check whether the force profile input set is now fully set or not
        if (self.forceProfileUserInputs.nbInputs == self.requiredNbForceProfileInputs) {
            // Disable further inputs
            self.enableUserInput = NO;
            
            self.forceProfileIsFullySet = YES;
            [self.parentViewController forceProfileInputSetStateChanged];
        }
        
        [self.userInput clear];
    }
    else {
        [self addErroneousInput : self.userInput];
        [self handleErroneousUserInput];
        
        // In case of error, reset the force profile input set
        [self.forceProfileUserInputs clear];
        self.nbForceProfileInputs = 0;
        
        [self.parentViewController nbForceProfileInputChanged];
    }
    
}

@end
