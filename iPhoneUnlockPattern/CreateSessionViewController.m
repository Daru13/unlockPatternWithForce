//
//  NewSessionViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 26/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "CreateSessionViewController.h"
#import "UPFExperimentUser.h"
#import "UPFExperimentSession.h"

@implementation CreateSessionViewController

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

- (void) initPropertiesWithDefaultValues {
    // Get the shared experiment instance
    // self.relatedExperiment = [UPFExperiment sharedExperiment];
    
    // Set default values to other properties, except if they have been pre-set
    self.sessionNumberHasBeenSet = NO;
    
    if (! self.sessionNumberHasBeenPreset)
        self.sessionNumberValue = 0;
}

// --------------------------------------------------------------
// VIEW LIFECYCLE CALLBACKS
// --------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"CreateSessionViewController's view loaded");
    
    // Do some initialization
    [self initPropertiesWithDefaultValues];
    [self updateViewWithPresetValues];
}

// --------------------------------------------------------------
// SESSION ADDITION
// --------------------------------------------------------------

// If a userId has been set AND is available, return YES; otherwise, return NO
- (BOOL) newSessionCanBeCreated {
    return (self.sessionNumberHasBeenSet || self.sessionNumberHasBeenPreset)
        && [self.relatedUser sessionNumberIsAvailable : self.sessionNumberValue];
}

// If the new user could be created, return YES; otherwise, return NO
- (BOOL) createNewSession {
    // Check if the session number is available
    if (! [self newSessionCanBeCreated])
        return NO;
    
    // Get the session input mode from the related UI control
    UPFSessionInputMode mainInputMode = -1;
    switch (self.inputModeSegmentedControl.selectedSegmentIndex) {
        case 0: // Single hand
            mainInputMode = SESSION_INPUT_MODE_SINGLE_HAND;
            break;
        case 1: // Two hands
            mainInputMode = SESSION_INPUT_MODE_TWO_HANDS;
            break;
        case 2: // Tabletop
            mainInputMode = SESSION_INPUT_MODE_TABLETOP;
            break;
    }
    
    // Get the steps order from the related UI control
    UPFSessionStepsOrder stepsOrder = -1;
    switch (self.stepsOrderSegmentedControl.selectedSegmentIndex) {
        case 0: // Normal
            stepsOrder = SESSION_STEPS_ORDER_NORMAL;
            break;
        case 1: // Shuffled
            stepsOrder = SESSION_STEPS_ORDER_SHUFFLED;
            break;
    }
    
    // Create and add a new session to the related user
    UPFExperimentSession* newSession = [UPFExperimentSession createSessionWithNumber : self.sessionNumberValue
                                                                              userId : self.relatedUser.userId
                                                                       mainInputMode : mainInputMode];
    newSession.stepsOrder = stepsOrder;
    
    [self.relatedUser addSession : newSession];
    
    return YES;
}

// --------------------------------------------------------------
// UI UPDATE
// --------------------------------------------------------------


// If values have been preset by a prior controller (e.g. session number), pre-update the view accordingly
- (void) updateViewWithPresetValues {
    if (self.sessionNumberHasBeenPreset)
        self.sessionNumberTextField.text = [NSString stringWithFormat : @"%d", self.sessionNumberValue];
    
    [self updateCreateNewSessionButtonState];
}

- (void) updateCreateNewSessionButtonState {
    if ([self newSessionCanBeCreated])
        self.createNewSessionButton.enabled = YES;
    else
        self.createNewSessionButton.enabled = NO;
}

// --------------------------------------------------------------
// UI CONTROLS CALLBACKS
// --------------------------------------------------------------

- (IBAction) sessionNumberTextFieldEditingDidEnd : (UITextField*) sender {
    self.sessionNumberValue = [sender.text intValue];
    
    // Mark this value as set
    self.sessionNumberHasBeenSet = YES;
    
    [self updateCreateNewSessionButtonState];
}

- (IBAction) createNewSessionButtonPressed : (id) sender {
    BOOL sessionCreationSuccess = [self createNewSession];
    
    NSLog(@"Add session button pressed: success = %d", sessionCreationSuccess);
    
    // If the session creation was a success, move back to the list of sessions
    if (sessionCreationSuccess)
        [self.navigationController popViewControllerAnimated : YES];
}

- (BOOL) textFieldShouldReturn : (UITextField*) textField {
    [textField resignFirstResponder];
    return NO;
}

@end
