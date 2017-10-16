//
//  TrainingStepPatternView.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 07/07/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "TrainingStepPatternView.h"

@implementation TrainingStepPatternView

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

// Override to initialize additional properties
- (void) initPropertiesWithDefaultValues {
    // Initialize all regular properties
    [super initPropertiesWithDefaultValues];
    
    // Default init of additional properties
    [self resetTrainingInputsWith : nil];
}

// --------------------------------------------------------------
// USER INPUTS
// --------------------------------------------------------------

- (void) resetTrainingInputsWith : (UPFPatternInputSet*) inputSet {
    self.trainingInputs = inputSet;
}

- (void) addInput : (UPFPatternInput*) input {
    [self.trainingInputs addInput : input];
}

// --------------------------------------------------------------
// REGULAR MULTITOUCH EVENTS PROCESSING
// --------------------------------------------------------------

- (void) onTouchEnded {
    [self addInput : self.userInput];
    [self.userInput clear];
}

@end
