//
//  AddUserViewController.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 26/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPFExperiment.h"
#import "UPFExperimentUser.h"

@interface CreateUserViewController : UIViewController

@property UPFExperiment* relatedExperiment;

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

@property BOOL      userIdHasBeenSet;
@property UPFUserId userIdInputValue;

// IB outlets
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *handednessSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createNewUserButton;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (BOOL) newUserCanBeCreated;
- (BOOL) createNewUser;

- (IBAction) userIdTextFieldEditingDidEnd : (UITextField *)sender;
- (IBAction) createNewUserButtonPressed : (id) sender;
- (BOOL) textFieldShouldReturn : (UITextField*) textField;

@end
