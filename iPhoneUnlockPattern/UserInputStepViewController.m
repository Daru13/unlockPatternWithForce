//
//  UserInputStepViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 30/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UserInputStepViewController.h"
#import "UserInputStepPatternView.h"
#import "PatternViewController.h"
#import "UPFExperiment.h"
#import "UPFExperimentUser.h"
#import "UPFExperimentSession.h"
#import "UPFExperimentReferencePathStep.h"
#import "UPFExperimentUserInputStep.h"
#import "UPFPatternInputSet.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UserInputStepViewController ()

@property (readwrite) UPFUserMainHand mainHand;

@property (readwrite) UPFSessionInputMode firstInputMode;
@property (readwrite) UPFSessionInputMode secondInputMode;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UserInputStepViewController
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

- (void) initInputModes {
    // The first input mode is the main input mode specified in the session parameters
    self.firstInputMode = self.relatedSession.mainInputMode;
    
    // The second input mode is the other available one
    self.secondInputMode = self.firstInputMode == SESSION_INPUT_MODE_SINGLE_HAND
                         ? SESSION_INPUT_MODE_TWO_HANDS
                         : SESSION_INPUT_MODE_SINGLE_HAND;
}

- (void) initPropertiesWithDefaultValues {
    // Set the main hand et the input modes
    [self initMainHand];
    [self initInputModes];
    
    NSLog(@"Init of UserInputStepViewController ended: main hand is %d, first input mode is %d",
          self.mainHand, self.firstInputMode);
}

// --------------------------------------------------------------
// VIEW LIFECYCLE
// --------------------------------------------------------------

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : animated];
    
    // Initial substep update
    [self updateCurrentSubstep];
    
    // Reset the embedded pattern view's user input set
    [self.embeddedPatternView resetUserInputsWith : [self.currentUserInputStep getInputSetRelatedToCurrentSubtep]
                                                  : [self.currentUserInputStep getNbRequiredInputsRelatedToCurrentSubstep]];
    
    [self updateNavigationBar];
}

// --------------------------------------------------------------
// STEP ENDING
// --------------------------------------------------------------

// Depending on internal states, ending (the current) user input step may result in:
// 1. Going back to force profile input, if another force profile is expected
// 2. Going back to reference path presentation, if another reference path exists
// 3. Finishing current session, and thus termianting the experiment

// This method should be called once current set is finished
- (void) endCurrentStepAndSegueToContinueExperiment {
    // First, properly finish current user input step
    // If this was the last user input step for the current reference path, current reference path is finished as well
    [self.currentReferencePathStep finishCurrentUserInputStep];
    
    // If current reference path has been finished, notify the session it finished
    // If this was the last reference path step for current session, current session is finished as well
    if (self.currentReferencePathStep.isFinished)
        [self.relatedSession finishCurrentPathStep];
    
    NSLog(@"Before final segue: %d %d",
          self.relatedSession.isFinished,
          self.currentReferencePathStep.isFinished);
    
    // Finally, perform the right segue according to what has been finished
    if (self.relatedSession.isFinished) {
        NSLog(@"Session %@ is finished!", self.relatedSession);
        [self performSegueWithIdentifier : @"UnwindToExperimentUsersTableViewSegue" sender : self];
    }
    
    else if (self.currentReferencePathStep.isFinished)
        [self performSegueWithIdentifier : @"UnwindToDisplayReferencePathStepSegue" sender : self];
    
    else
        [self performSegueWithIdentifier : @"UnwindToForceProfileInputStepSegue" sender : self];
}

// --------------------------------------------------------------
// ALERT POPUPS
// --------------------------------------------------------------

- (NSString*) getAlertTitleAsString {
    switch (self.currentUserInputStep.substep) {
        case USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT:
            return @"Single-hand input";
            
        case USER_INPUT_SUBSTEP_TWO_HANDS_INPUT:
            return @"Two-hands input";
            
        case USER_INPUT_SUBSTEP_ENDED:
            return @"Done, thank you!";
            
        case USER_INPUT_SUBSTEP_NOT_STARTED:
        default:
            return @"(No input required)";
    }
}


- (NSString*) getAlertInstructionsAsString {
    // Handedness-insensitive cases
    if (self.currentUserInputStep.substep == USER_INPUT_SUBSTEP_ENDED)
        return @"Please press the button to further continue the experiment.";
    
    if (self.currentUserInputStep.substep == USER_INPUT_SUBSTEP_NOT_STARTED)
        return @"(No instruction)";
    
    // Handedness-sensitive cases
    switch (self.mainHand) {
        case MAIN_HAND_RIGHT:
        case MAIN_HAND_AMBIDEXTROUS: // TODO: handle ambidextrous differently?
            switch (self.currentUserInputStep.substep) {
                case USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT:
                    return [NSString stringWithFormat : @"Hold the phone in your RIGHT HAND, and use your RIGHT THUMB to enter the path you've seen with the same force profile as the one you've chosen before. You must repeat this %d times!",
                            [self.currentUserInputStep getNbRequiredInputsRelatedToCurrentSubstep]];
                    
                case USER_INPUT_SUBSTEP_TWO_HANDS_INPUT:
                    return [NSString stringWithFormat : @"Hold the phone in your LEFT HAND, and use your RIGHT HAND to enter the path you've seen with the same force profile as the one you've chosen before. You must repeat this %d times!",
                            [self.currentUserInputStep getNbRequiredInputsRelatedToCurrentSubstep]];
                    
                default:
                    return @"(Unknown substep: no instruction)";
            }
            break;
            
        case MAIN_HAND_LEFT:
            switch (self.currentUserInputStep.substep) {
                case USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT:
                    return [NSString stringWithFormat : @"Hold the phone in your LEFT HAND, and use your LEFT THUMB to enter the path you've seen with the same force profile as the one you've chosen before. You must repeat this %d times!",
                            [self.currentUserInputStep getNbRequiredInputsRelatedToCurrentSubstep]];
                    
                case USER_INPUT_SUBSTEP_TWO_HANDS_INPUT:
                    return [NSString stringWithFormat : @"Hold the phone in your RIGHT HAND, and use your LEFT HAND to enter the path you've seen with the same force profile as the one you've chosen before. You must repeat this %d times!",
                            [self.currentUserInputStep getNbRequiredInputsRelatedToCurrentSubstep]];
                    
                default:
                    return @"(Unknown substep: no instruction)";
            }
            break;
    }
}

// Specific alert popup opener; should be called before the first substep
- (void) openAlertBeforeStartingFirstSubstep {
    [self openAlertWithTitle : [self getAlertTitleAsString]
                     message : [self getAlertInstructionsAsString]
                 actionTitle : @"Start"
                      action : ALERT_POPUP_NO_ACTION];
}

// Specific alert popup opener; should be called before the second substep
- (void) openAlertBeforeStartingSecondSubstep {
    [self openAlertWithTitle : [self getAlertTitleAsString]
                     message : [self getAlertInstructionsAsString]
                 actionTitle : @"Continue"
                      action : ALERT_POPUP_NO_ACTION];
}

// Specific alert popup opener; should be called after the second step has ended
- (void) openAlertBeforeEndingCurrentStep {
    [self openAlertWithTitle : [self getAlertTitleAsString]
                     message : [self getAlertInstructionsAsString]
                 actionTitle : @"Continue experiment"
                      action : ^(UIAlertAction * action){
                          [self endCurrentStepAndSegueToContinueExperiment];
                      }];
}

// --------------------------------------------------------------
// SUB-STEPS
// --------------------------------------------------------------

- (UPFUserInputSubstep) getSubstepFromInputMode : (UPFSessionInputMode) inputMode {
    switch (inputMode) {
        case SESSION_INPUT_MODE_SINGLE_HAND:
            return USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT;
            
        case SESSION_INPUT_MODE_TWO_HANDS:
            return USER_INPUT_SUBSTEP_TWO_HANDS_INPUT;
            
        default:
        case SESSION_INPUT_MODE_TABLETOP: // not handled
            return USER_INPUT_SUBSTEP_NOT_STARTED;
    }
}

// In the beginning, the substep is set acordingly to the (suposedly already set) first input mode
// If the set related to the first substep is full, then the substep is set accordingly to the second input mode
- (void) updateCurrentSubstep {
    UPFUserInputSubstep firstSubstep  = [self getSubstepFromInputMode : self.firstInputMode];
    UPFUserInputSubstep secondSubstep = [self getSubstepFromInputMode : self.secondInputMode];
    
    // Determine what is the next substep
    UPFUserInputSubstep nextSubstep = firstSubstep;

    if (self.currentUserInputStep.substep == firstSubstep
    &&  self.embeddedPatternView.userInputSetIsFull)
        nextSubstep = secondSubstep;
    
    else if (self.currentUserInputStep.substep == secondSubstep
    &&  self.embeddedPatternView.userInputSetIsFull)
        nextSubstep = USER_INPUT_SUBSTEP_ENDED;
    
    // Actually update the substep
    [self.currentUserInputStep updateSubstepWith : nextSubstep];
    
    NSLog(@"Updating current SUB step of %@ to %d", self.currentUserInputStep, nextSubstep);
    
    // Display an alert popup to inform the user, if required
    if (nextSubstep == firstSubstep)
        [self openAlertBeforeStartingFirstSubstep];
    else if (nextSubstep == secondSubstep)
        [self openAlertBeforeStartingSecondSubstep];
    else if (nextSubstep == USER_INPUT_SUBSTEP_ENDED)
        [self openAlertBeforeEndingCurrentStep];
}

// --------------------------------------------------------------
// EMBEDDED VIEW CALLBACKS
// --------------------------------------------------------------

- (void) nbUserInputsChanged {
    // Update the navigation bar to update the progress info
    [self updateNavigationBar];
    
    // Possibly change the state of the undo button
    [self updateUndoLastInputButtonState];
}

- (void) userInputSetStateChanged {
    NSLog(@"State changed: %d", self.embeddedPatternView.userInputSetIsFull);
    
    // Make sure the input set is full; otherwise, do nothing
    if (! self.embeddedPatternView.userInputSetIsFull)
        return;
    
    // Save a copy of the erroneous input set to the right property
    if (self.currentUserInputStep.substep == USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT)
        self.currentUserInputStep.singleHandErroneousInputs = self.embeddedPatternView.erroneousUserInputs;
    else if (self.currentUserInputStep.substep == USER_INPUT_SUBSTEP_TWO_HANDS_INPUT)
        self.currentUserInputStep.twoHandsErroneousInputs = self.embeddedPatternView.erroneousUserInputs;
    
    // Update the substep and the specialized pattern view accordingly
    [self updateCurrentSubstep];
    [self.embeddedPatternView resetUserInputsWith : [self.currentUserInputStep getInputSetRelatedToCurrentSubtep]
                                                  : [self.currentUserInputStep getNbRequiredInputsRelatedToCurrentSubstep]];
    
    [self updateNavigationBar];
    [self updateUndoLastInputButtonState];
}

// --------------------------------------------------------------
// EMBEDDED VIEW UPDATE
// --------------------------------------------------------------

- (void) updateEmbeddedPatternViewParameters {
    self.embeddedPatternView.enableUserInput                                 = YES;
    self.embeddedPatternView.enablePatternReferenceInputPathDrawing          = NO;
    self.embeddedPatternView.enablePatternReferenceInputTouchEventLogDrawing = NO;
    self.embeddedPatternView.enableUserInputTouchEventLogDrawing             = NO;
    
    // TODO: Set the view touch ended callback
    NSLog(@"Parameters updated for USER_INPUT_STEP_STATE_(SINGLE/TWO)_HAND(S)_INPUT");
}

// --------------------------------------------------------------
// NAVIGATION BAR UPDATE
// --------------------------------------------------------------

- (NSString*) getTitleInstructionsAsString {
    switch (self.mainHand) {
        case MAIN_HAND_RIGHT:
        case MAIN_HAND_AMBIDEXTROUS:
            switch (self.currentUserInputStep.substep) {
                case USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT:
                    return [NSString stringWithFormat : @"SINGLE hand (RIGHT) — %d/%d",
                            self.embeddedPatternView.nbUserInputs,
                            self.embeddedPatternView.requiredNbUserInputs];
                case USER_INPUT_SUBSTEP_TWO_HANDS_INPUT:
                    return [NSString stringWithFormat : @"TWO hands (hold: LEFT) — %d/%d",
                            self.embeddedPatternView.nbUserInputs,
                            self.embeddedPatternView.requiredNbUserInputs];
                
                case USER_INPUT_SUBSTEP_NOT_STARTED:
                case USER_INPUT_SUBSTEP_ENDED:
                default:
                    return @"";
            }
            break;
            
        case MAIN_HAND_LEFT:
            switch (self.currentUserInputStep.substep) {
                case USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT:
                    return [NSString stringWithFormat : @"SINGLE hand (LEFT) — %d/%d",
                            self.embeddedPatternView.nbUserInputs,
                            self.embeddedPatternView.requiredNbUserInputs];
                    
                case USER_INPUT_SUBSTEP_TWO_HANDS_INPUT:
                    return [NSString stringWithFormat : @"TWO hands (hold: RIGHT) — %d/%d",
                            self.embeddedPatternView.nbUserInputs,
                            self.embeddedPatternView.requiredNbUserInputs];
                    
                case USER_INPUT_SUBSTEP_NOT_STARTED:
                case USER_INPUT_SUBSTEP_ENDED:
                default:
                    return @"";
            }
            break;
    }
}

- (NSString*) getUpdatedNavigationBarTitle {
    return [self getTitleInstructionsAsString];
}

- (NSString*) getUpdatedNavigationBarPrompt {
    return [NSString stringWithFormat : @"Reference path %d/%d – Force profile %d/%d",
            self.relatedSession.nbPathStepsCompleted + 1,
            self.relatedSession.nbPathStepsToPerform,
            self.currentReferencePathStep.nbUserInputStepsCompleted + 1,
            self.currentReferencePathStep.nbUserInputStepsToPerform];
}

// --------------------------------------------------------------
// UI UPDATE
// --------------------------------------------------------------

- (void) updateUndoLastInputButtonState {
    if ([self.embeddedPatternView lastSavedInputCanBeCanceled])
        self.undoLastInputButton.enabled = YES;
    else
        self.undoLastInputButton.enabled = NO;
}

// --------------------------------------------------------------
// UI CONTROLS CALLBACKS
// --------------------------------------------------------------

- (IBAction) undoLastInputButtonPressed : (UIBarButtonItem *) sender {
    // Canel the last saved input (if the button could be pressed, one can assume this will work)
    [self.embeddedPatternView cancelLastSavedInput];
}

// --------------------------------------------------------------
// SEGUE CALLBACK
// --------------------------------------------------------------

// Override this method, since the pattern view is specialized for this step
- (void) prepareForEmbeddedPatternViewSegue : (UIStoryboardSegue*) segue
                                            : (id) sender {
    NSLog(@"PREPARE FOR USER INPUTS EMBEDDED PATTERN VIEW SEGUE");
    
    // Perform regular emebedded view preparation
    [super prepareForEmbeddedPatternViewSegue : segue : sender];
    
    // Get (and save) a reference to the embedded, specialized pattern view
    PatternViewController* emebeddedPatternViewController = segue.destinationViewController;
    self.embeddedPatternView = (UserInputStepPatternView*) emebeddedPatternViewController.view;
    
    // Set the parent view's controller
    self.embeddedPatternView.parentViewController = self;
}

// Delegate each segue handling to different methods, one per segue identifier
- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender {
    [super prepareForSegue : segue
                    sender : sender];
}

@end
