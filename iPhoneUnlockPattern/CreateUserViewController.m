//
//  AddUserViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 26/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "CreateUserViewController.h"
#import "UPFExperiment.h"
#import "UPFExperimentUser.h"

@implementation CreateUserViewController

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

- (void) initPropertiesWithDefaultValues {
    // Get the shared experiment instance
    self.relatedExperiment = [UPFExperiment sharedExperiment];
    
    // Set default values to other properties
    self.userIdInputValue = 0;
    self.userIdHasBeenSet = NO;
}

// --------------------------------------------------------------
// VIEW LIFECYCLE CALLBACKS
// --------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"AddUserViewController's view loaded");
    
    // Do some initialization
    [self initPropertiesWithDefaultValues];
}

// --------------------------------------------------------------
// USER ADDITION
// --------------------------------------------------------------

// If a userId has been set AND is available, return YES; otherwise, return NO
- (BOOL) newUserCanBeCreated {
    return  self.userIdHasBeenSet
        && [self.relatedExperiment userIdIsAvailable : self.userIdInputValue];
}

// If the new user could be created, return YES; otherwise, return NO
- (BOOL) createNewUser {
    // Check if the user ID is available
    if (! [self newUserCanBeCreated])
        return NO;
    
    // Get the new user's handedness
    UPFUserMainHand mainHand = -1;
    switch (self.handednessSegmentedControl.selectedSegmentIndex) {
        case 0: // Left-handed
            mainHand = MAIN_HAND_LEFT;
            break;
        case 1: // Ambidextrous
            mainHand = MAIN_HAND_AMBIDEXTROUS;
            break;
        case 2: // Right-handed
            mainHand = MAIN_HAND_RIGHT;
            break;
    }
    
    // Create and add a new user to the related experiment
    UPFExperimentUser* newUser = [UPFExperimentUser createUserWithId : self.userIdInputValue
                                                            mainHand : mainHand];
    [self.relatedExperiment addUser : newUser];
    
    return YES;
}

// --------------------------------------------------------------
// UI CONTROLS UPDATE
// --------------------------------------------------------------

- (void) updateCreateNewUserButtonState {
    if ([self newUserCanBeCreated])
        self.createNewUserButton.enabled = YES;
    else
        self.createNewUserButton.enabled = NO;
}

// --------------------------------------------------------------
// UI CONTROLS CALLBACKS
// --------------------------------------------------------------

- (IBAction) userIdTextFieldEditingDidEnd : (UITextField *) sender {
    self.userIdInputValue = [sender.text intValue];
    
    // Mark this value as set
    self.userIdHasBeenSet = YES;
    
    [self updateCreateNewUserButtonState];
}

- (IBAction) createNewUserButtonPressed : (id) sender {
    BOOL userCreationSuccess = [self createNewUser];
    
    NSLog(@"Add user button pressed: success = %d", userCreationSuccess);
    
    // If the user creation was a success, move back to the list of users
    if (userCreationSuccess)
        [self.navigationController popViewControllerAnimated : YES];
}

- (BOOL) textFieldShouldReturn : (UITextField*) textField {
    [textField resignFirstResponder];
    return NO;
}

@end
