//
//  TrainingStepViewController.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "StepViewController.h"
#import "TrainingStepPatternView.h"

@interface TrainingStepViewController : StepViewController

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Specialization of the referenced, dynamicaly set pattern view's type
@property (weak, nonatomic) TrainingStepPatternView* embeddedPatternView;


// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------


@end
