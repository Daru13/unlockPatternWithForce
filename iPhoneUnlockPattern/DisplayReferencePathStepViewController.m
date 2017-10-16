//
//  DisplayReferencePathStepViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "DisplayReferencePathStepViewController.h"

@implementation DisplayReferencePathStepViewController

// --------------------------------------------------------------
// VIEW LIFECYCLE
// --------------------------------------------------------------

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : animated];
    
    // (Re-)create a fresh pattern from current reference path, and assign it to the embedded view
    [self resetCurrentPatternFromReferencePath];
    self.embeddedPatternView.pattern = self.currentPattern;
}

// --------------------------------------------------------------
// EMBEDDED VIEW UPDATE
// --------------------------------------------------------------

- (void) updateEmbeddedPatternViewParameters {
    self.embeddedPatternView.enableUserInput                                 = NO;
    self.embeddedPatternView.enablePatternReferenceInputPathDrawing          = YES;
    self.embeddedPatternView.enablePatternReferenceInputTouchEventLogDrawing = YES;
    self.embeddedPatternView.enableUserInputTouchEventLogDrawing             = NO;
    
    NSLog(@"Parameters updated for USER_INPUT_STEP_STATE_DISPLAY_REFERENCE_INPUT");}

// --------------------------------------------------------------
// NAVIGATION BAR UPDATE
// --------------------------------------------------------------

- (NSString*) getUpdatedNavigationBarTitle {
    return [NSString stringWithFormat : @"Reference path n°%d",
            self.relatedSession.nbPathStepsCompleted + 1];
}

- (NSString*) getUpdatedNavigationBarPrompt {
    return [NSString stringWithFormat : @""];
}

// --------------------------------------------------------------
// SEGUE CALLBACK
// --------------------------------------------------------------

- (void) prepareForStartForceProfileInputSegue : (UIStoryboardSegue*) segue
                                               : (id) sender {
    NSLog(@"PREPARE FOR FORCE PROFILE INPUT SEGUE");
    
    // Generically prepare the next step view controller
    [self prepareForGenericNextStep : segue : sender];
    
    // Change the current input step's state
    [self.currentUserInputStep startForceProfileInputMode];
}

// Delegate each segue handling to different methods, one per segue identifier
- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender {
    [super prepareForSegue : segue
                    sender : sender];
    
    if ([segue.identifier isEqualToString : @"StartForceProfileInputSegue"])
        [self prepareForStartForceProfileInputSegue : segue : sender];
}

// Allow (and prepare) unwinding to this view controller
- (IBAction) prepareForUnwindToDisplayReferencePathStep : (UIStoryboardSegue *) segue {
    NSLog(@"Prepare unwind to ForceProfileInputStepVC");
}

@end
