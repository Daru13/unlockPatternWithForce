//
//  ReferencePathStepViewController.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 28/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatternView.h"
#import "UPFExperimentSession.h"
#import "UPFExperimentReferencePathStep.h"
#import "UPFExperimentUserInputStep.h"
#import "UPFPattern.h"

// Constant macro meaning popup must have no other action than closing itself
#define ALERT_POPUP_NO_ACTION ^(UIAlertAction * action){}


@interface StepViewController : UIViewController

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Reference session and path step to represent
@property UPFExperimentSession* relatedSession;

// Current reference path step and user input step
@property (readonly) UPFExperimentUserInputStep*     currentUserInputStep;
@property (readonly) UPFExperimentReferencePathStep* currentReferencePathStep;

// Current reference pattern
@property UPFPattern* currentPattern;

// IB Outlets
@property (weak, nonatomic) IBOutlet UINavigationBar *stepNavigationBar;

// Ref. to the dynamically set embedded view
@property (weak, nonatomic) PatternView* embeddedPatternView;


// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) updateCurrentReferencePathStep;
- (void) updateCurrentUserInputStep;
- (void) updateCurrentSteps;

- (UPFPattern*) getFreshPatternFromReferencePath;
- (void) resetCurrentPatternFromReferencePath;

- (void) updateEmbeddedPatternViewParameters;
- (void) updateEmbeddedPatternView;

- (NSString*) getUpdatedNavigationBarTitle;
- (void) updateNavigationBarTitleWith : (NSString*) newTitle;
- (void) updateNavigationBarTitle;
- (NSString*) getUpdatedNavigationBarPrompt;
- (void) updateNavigationBarPromptWith : (NSString*) newPrompt;
- (void) updateNavigationBarPrompt;
- (void) updateNavigationBar;

- (void) openAlertWithTitle : (NSString*) title
                    message : (NSString*) message
                actionTitle : (NSString*) actionTitle
                     action : (void (^)(UIAlertAction * action)) action;

- (void) prepareForGenericNextStep : (UIStoryboardSegue*) segue : (id) sender;
- (void) prepareForEmbeddedPatternViewSegue    : (UIStoryboardSegue*) segue : (id) sender;
- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender;

@end
