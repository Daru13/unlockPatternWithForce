//
//  NewSessionViewController.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 26/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPFExperimentUser.h"

@interface CreateSessionViewController : UIViewController

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

@property UPFExperimentUser* relatedUser;

@property BOOL         sessionNumberHasBeenPreset;
@property BOOL         sessionNumberHasBeenSet;
@property unsigned int sessionNumberValue;

// IB outlets
@property (weak, nonatomic) IBOutlet UITextField *sessionNumberTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *inputModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *stepsOrderSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createNewSessionButton;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (BOOL) newSessionCanBeCreated;
- (BOOL) createNewSession;

- (IBAction) sessionNumberTextFieldEditingDidEnd : (UITextField*) sender;
- (IBAction) createNewSessionButtonPressed : (id) sender;
- (BOOL) textFieldShouldReturn : (UITextField*) textField;

@end
