//
//  TrainingStepViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "TrainingStepViewController.h"
#import "UserInputStepViewController.h"
#import "TrainingStepPatternView.h"
#import "PatternViewController.h"
#import "UPFPatternInputSet.h"

@implementation TrainingStepViewController
@dynamic embeddedPatternView;

// --------------------------------------------------------------
// VIEW LIFECYCLE
// --------------------------------------------------------------

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : animated];
    
    // Create a single use "useless" pattern, for training purposes only
    // It will be replaced by newly created patterns in further steps of the experiment
    [self resetCurrentPatternFromReferencePath];
    self.embeddedPatternView.pattern = self.currentPattern;
    
    // Reset the embedded pattern view's user input set
    [self.embeddedPatternView resetTrainingInputsWith : self.relatedSession.trainingInputSet];
}

// --------------------------------------------------------------
// EMBEDDED VIEW UPDATE
// --------------------------------------------------------------

- (void) updateEmbeddedPatternViewParameters {
    self.embeddedPatternView.enableUserInput                                 = YES;
    self.embeddedPatternView.enablePatternReferenceInputPathDrawing          = NO;
    self.embeddedPatternView.enablePatternReferenceInputTouchEventLogDrawing = YES;
    self.embeddedPatternView.enableUserInputTouchEventLogDrawing             = YES;
    
    NSLog(@"Parameters updated for USER_INPUT_STEP_STATE_TRAINING");
}

// --------------------------------------------------------------
// NAVIGATION BAR UPDATE
// --------------------------------------------------------------

- (NSString*) getUpdatedNavigationBarTitle {
    return [NSString stringWithFormat : @"Training mode"];
}

- (NSString*) getUpdatedNavigationBarPrompt {
    return nil;
}

// --------------------------------------------------------------
// SEGUE CALLBACK
// --------------------------------------------------------------

// Override this method, since the pattern view is specialized for this step
- (void) prepareForEmbeddedPatternViewSegue : (UIStoryboardSegue*) segue
                                            : (id) sender {
    NSLog(@"PREPARE FOR TRAINING STEP EMBEDDED PATTERN VIEW SEGUE");
    
    // Perform regular emebedded view preparation
    [super prepareForEmbeddedPatternViewSegue : segue : sender];
    
    // Get (and save) a reference to the embedded, specialized pattern view
    PatternViewController* emebeddedPatternViewController = segue.destinationViewController;
    self.embeddedPatternView = (TrainingStepPatternView*) emebeddedPatternViewController.view;
}

- (void) prepareForReferencePathDisplaySegue : (UIStoryboardSegue*) segue
                                             : (id) sender {
    NSLog(@"PREPARE FOR START REFERENCE PATH DISPLAY MODE SEGUE");
    
    // Generically prepare the next step view controller
    [self prepareForGenericNextStep : segue : sender];
    
    // Change the current input step's state
    [self.currentUserInputStep startUserInputMode];
}

// Delegate each segue handling to different methods, one per segue identifier
- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender {
    [super prepareForSegue : segue
                    sender : sender];
    
    if ([segue.identifier isEqualToString : @"StartReferencePathDisplaySegue"])
        [self prepareForReferencePathDisplaySegue : segue : sender];
}

@end
