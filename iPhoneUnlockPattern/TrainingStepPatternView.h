//
//  TrainingStepPatternView.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 07/07/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "PatternView.h"
#import "UPFPatternInputSet.h"

@interface TrainingStepPatternView : PatternView

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Reference to the input set where to save training inputs
@property UPFPatternInputSet* trainingInputs;


// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) resetTrainingInputsWith : (UPFPatternInputSet*) inputSet;

@end
