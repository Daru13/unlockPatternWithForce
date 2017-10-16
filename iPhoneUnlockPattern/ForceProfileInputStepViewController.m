//
//  ForceProfileInputViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "ForceProfileInputStepViewController.h"
#import "PatternViewController.h"
#import "ForceProfileInputStepPatternView.h"
#import "UPFExperiment.h"

// ----------------------------------------------------------------- Internal interface ---

@interface ForceProfileInputStepViewController ()

@property (readwrite) UPFUserMainHand mainHand;

@property (readwrite) UPFSessionInputMode mainInputMode;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation ForceProfileInputStepViewController
@dynamic embeddedPatternView;

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

- (void) initMainHand {
    // TODO: do this in a cleaner way
    
    // The main hand is based on the user handedness
    NSInteger userIndex = [[UPFExperiment sharedExperiment].users indexOfObjectPassingTest :
                           ^BOOL(UPFExperimentUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                               return self.relatedSession.userId == obj.userId;
                           }];
    self.mainHand = [UPFExperiment sharedExperiment].users[userIndex].mainHand;
}

- (void) initMainInputMode {
    // The first input mode is the main input mode specified in the session parameters
    self.mainInputMode = self.relatedSession.mainInputMode;
}

- (void) initPropertiesWithDefaultValues {
    // Set the main hand and input mode
    [self initMainHand];
    [self initMainInputMode];
}

// --------------------------------------------------------------
// VIEW LIFECYCLE
// --------------------------------------------------------------

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : animated];
    
    // Reset the embedded view
    [self.embeddedPatternView initPropertiesWithDefaultValues];
    
    // (Re-)create a fresh pattern from current reference path, and assign it to the embedded view
    [self resetCurrentPatternFromReferencePath];
    self.embeddedPatternView.pattern = self.currentPattern;
    
    // Update the navigation bar, so it display info about the freshly reset view
    [self updateNavigationBar];
    [self updateContinueToTrainingModeButtonState];
    
    // Finally, open a popup to introduce the user to what they must do at this point
    [self openAlertBeforeStartingForceProfileInput];
}

// --------------------------------------------------------------
// ALERT POPUPS
// --------------------------------------------------------------

- (NSString*) getAlertTitleAsString {
    switch (self.mainInputMode) {
        case SESSION_INPUT_MODE_SINGLE_HAND:
            return @"Single-hand input";
            
        case SESSION_INPUT_MODE_TWO_HANDS:
            return @"Two-hands input";
            
        default:
        case SESSION_INPUT_MODE_TABLETOP:
            return @"(Not handled)";
    }
}

- (NSString*) getAlertInstructionsAsString {
    switch (self.mainHand) {
        case MAIN_HAND_RIGHT:
        case MAIN_HAND_AMBIDEXTROUS: // TODO: handle ambidextrous differently?
            switch (self.mainInputMode) {
                case SESSION_INPUT_MODE_SINGLE_HAND:
                    return [NSString stringWithFormat : @"Hold the phone in your RIGHT HAND, and use your RIGHT THUMB to define your own force profile, for the given path. You must repeat this %d times!",
                            self.embeddedPatternView.requiredNbForceProfileInputs];
                    
                case SESSION_INPUT_MODE_TWO_HANDS:
                    return [NSString stringWithFormat : @"Hold the phone in your LEFT HAND, and use your RIGHT HAND to define your own force profile, for the given path. You must repeat this %d times!",
                            self.embeddedPatternView.requiredNbForceProfileInputs];
                    
                default:
                case SESSION_INPUT_MODE_TABLETOP:
                    return @"(Unknown or unsupported input mode: no instruction)";
            }
            break;
            
        case MAIN_HAND_LEFT:
            switch (self.currentUserInputStep.substep) {
                case SESSION_INPUT_MODE_SINGLE_HAND:
                    return [NSString stringWithFormat : @"Hold the phone in your LEFT HAND, and use your LEFT THUMB to define your own force profile, for the given path. You must repeat this %d times!",
                            self.embeddedPatternView.requiredNbForceProfileInputs];
                    
                case SESSION_INPUT_MODE_TWO_HANDS:
                    return [NSString stringWithFormat : @"Hold the phone in your RIGHT HAND, and use your LEFT HAND to define your own force profile, for the given path. You must repeat this %d times!",
                            self.embeddedPatternView.requiredNbForceProfileInputs];
                    
                default:
                    return @"(Unknown substep: no instruction)";
            }
            break;
    }
}

// Specific alert popup opener; should be called before the force profile input starts
- (void) openAlertBeforeStartingForceProfileInput {
    [self openAlertWithTitle : [self getAlertTitleAsString]
                     message : [self getAlertInstructionsAsString]
                 actionTitle : @"OK"
                      action : ALERT_POPUP_NO_ACTION];
}

// --------------------------------------------------------------
// EMBEDDED VIEW CALLBACKS
// --------------------------------------------------------------

- (void) nbForceProfileInputChanged {
    [self updateNavigationBar];
}

- (void) forceProfileInputSetStateChanged {
    [self updateContinueToTrainingModeButtonState];
}

// --------------------------------------------------------------
// EMBEDDED VIEW UPDATE
// --------------------------------------------------------------

- (void) updateEmbeddedPatternViewParameters {
    self.embeddedPatternView.enableUserInput                                 = YES;
    self.embeddedPatternView.enablePatternReferenceInputPathDrawing          = YES;
    self.embeddedPatternView.enablePatternReferenceInputTouchEventLogDrawing = YES;
    self.embeddedPatternView.enableUserInputTouchEventLogDrawing             = YES;
    
    // TODO: Set the view touch ended callback
    NSLog(@"Parameters updated for USER_INPUT_STEP_STATE_FORCE_PROFILE_INPUT");
}

// --------------------------------------------------------------
// NAVIGATION BAR UPDATE
// --------------------------------------------------------------

- (void) updateContinueToTrainingModeButtonState {
    self.continueToTrainingModeButton.enabled = self.embeddedPatternView.forceProfileIsFullySet;
}

- (NSString*) getUpdatedNavigationBarTitle {
    return [NSString stringWithFormat : @"Force profile input: %d/%d",
            self.embeddedPatternView.nbForceProfileInputs,
            self.embeddedPatternView.requiredNbForceProfileInputs];
}

- (NSString*) getUpdatedNavigationBarPrompt {
    return [NSString stringWithFormat : @"Reference path %d/%d – Force profile %d/%d",
            self.relatedSession.nbPathStepsCompleted + 1,
            self.relatedSession.nbPathStepsToPerform,
            self.currentReferencePathStep.nbUserInputStepsCompleted + 1,
            self.currentReferencePathStep.nbUserInputStepsToPerform];
}

// --------------------------------------------------------------
// SEGUE CALLBACK
// --------------------------------------------------------------

// Override this method, since the pattern view is specialized for this step
- (void) prepareForEmbeddedPatternViewSegue : (UIStoryboardSegue*) segue
                                            : (id) sender {
    NSLog(@"PREPARE FOR FORCE PROFILE INPUT EMBEDDED PATTERN VIEW SEGUE");
    
    // Perform regular emebedded view preparation
    [super prepareForEmbeddedPatternViewSegue : segue : sender];
    
    // Get (and save) a reference to the embedded, specialized pattern view
    PatternViewController* emebeddedPatternViewController = segue.destinationViewController;
    self.embeddedPatternView = (ForceProfileInputStepPatternView*) emebeddedPatternViewController.view;
    
    // Set the parent view's controller
    self.embeddedPatternView.parentViewController = self;
}

- (void) prepareForStartUserInputsSegue : (UIStoryboardSegue*) segue
                                        : (id) sender {
    NSLog(@"PREPARE FOR START USER INPUT MODE MODE SEGUE");
    
    // Generically prepare the next step view controller
    [self prepareForGenericNextStep : segue : sender];
    
    // Save a copy of the force profile inputs (valid + erroenous ones)
    self.currentUserInputStep.forceProfileInputs          = self.embeddedPatternView.forceProfileUserInputs;
    self.currentUserInputStep.forceProfileErroneousInputs = self.embeddedPatternView.erroneousUserInputs;
    
    // Change the current input step's state
    [self.currentUserInputStep startUserInputMode];
}

// Delegate each segue handling to different methods, one per segue identifier
- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender {
    [super prepareForSegue : segue
                    sender : sender];
    
    if ([segue.identifier isEqualToString : @"StartUserInputsSegue"])
        [self prepareForStartUserInputsSegue : segue : sender];
}

// Allow (and prepare) unwinding to this view controller
- (IBAction) prepareForUnwindToForceProfileInputStep : (UIStoryboardSegue *) segue {
    NSLog(@"Prepare unwind to ForceProfileInputStepVC");
    
    // When coming back here for another, different force profile input,
    // the newly loaded user input step is not in the right mode by default
    [self updateCurrentSteps];
    [self.currentUserInputStep startForceProfileInputMode];
}

@end
