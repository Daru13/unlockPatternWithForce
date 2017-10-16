//
//  ReferencePathStepViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 28/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "StepViewController.h"
#import "PatternViewController.h"
#import "PatternView.h"
#import "UPFExperimentReferencePathStep.h"
#import "UPFExperimentUserInputStep.h"
#import "UPFPattern.h"
#import "UPFPatternInputSet.h"
#import "UPFPatternInput.h"

// ----------------------------------------------------------------- Internal interface ---

@interface StepViewController ()

@property (readwrite) UPFExperimentUserInputStep*     currentUserInputStep;
@property (readwrite) UPFExperimentReferencePathStep* currentReferencePathStep;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation StepViewController

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

- (void) initPropertiesWithDefaultValues {
    // Should be overriden by sublcasses
}

- (void) hideNavigationUselessControls {
    [self.navigationItem setHidesBackButton : YES
                                   animated : YES];
    [self.navigationController setToolbarHidden : YES
                                       animated : YES];
}

// --------------------------------------------------------------
// VIEW LIFECYCLE
// --------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];

    // Initialization
    [self initPropertiesWithDefaultValues];
    [self hideNavigationUselessControls];
}

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : animated];
    
    NSLog(@"\n\n---------------------------------------------------- View of step %@ \n", self);
    
    // Update internal steps
    [self updateCurrentSteps];
    
    // Perform some graphical updates/setup
    [self updateEmbeddedPatternView];
    [self updateNavigationBar];
}

- (void) viewDidAppear : (BOOL) animated {
    [super viewDidAppear : animated];
    
    // NSLog(@"\n\n-> %@ did appear\n\n", self);
}

// --------------------------------------------------------------
// CURRENT STEPS
// --------------------------------------------------------------

- (void) updateCurrentReferencePathStep {
    self.currentReferencePathStep = [self.relatedSession getCurrentReferencePathStep];
    
    NSLog(@"Current ref. path step has been set to %@ (%d/%d input steps)",
          self.currentReferencePathStep,
          self.currentReferencePathStep.nbUserInputStepsCompleted,
          self.currentReferencePathStep.nbUserInputStepsToPerform);
}

- (void) updateCurrentUserInputStep {
    self.currentUserInputStep = [self.currentReferencePathStep getCurrentUserInputStep];
    
    NSLog(@"Current user input step has been set to %@ (state is %d)",
          self.currentUserInputStep, self.currentUserInputStep.state);
}

- (void) updateCurrentSteps {
    [self updateCurrentReferencePathStep],
    [self updateCurrentUserInputStep];
}

// --------------------------------------------------------------
// REFERENCE PATTERN/PATH
// --------------------------------------------------------------

- (UPFPattern*) getFreshPatternFromReferencePath {
    // Create an input set, and fill it ith a new input containing the reference path
    UPFPatternInputSet* referenceInputSet = [UPFPatternInputSet createEmptyInputSetOfSize : 1];
    UPFPatternInput*    referenceInput    = [UPFPatternInput createFromPatternPath : self.currentReferencePathStep.referencePath
                                                                     touchEventLog : [UPFTouchEventLog createEmptyLog : @""]];
    
    [referenceInputSet addInput : referenceInput];
    
    // Create the fresh pattern, and set its reference input set
    UPFPattern* freshPattern       = [UPFPattern createPatternOfSize : 3 : 3];
    freshPattern.referenceInputSet = referenceInputSet;
    
    return freshPattern;
}

- (void) resetCurrentPatternFromReferencePath {
    self.currentPattern = [self getFreshPatternFromReferencePath];
}

// --------------------------------------------------------------
// EMBEDDED VIEW UPDATE
// --------------------------------------------------------------

- (void) updateEmbeddedPatternViewParameters {
    // Should be overriden by sublcasses, if required
}

- (void) updateEmbeddedPatternView {
    // Update the view's pattern
    self.embeddedPatternView.pattern = self.currentPattern;
    
    // Update the view parameters
    NSLog(@"Old view parameters (%d / %d / %d)",
          self.embeddedPatternView.enableUserInput,
          self.embeddedPatternView.enablePatternReferenceInputPathDrawing,
          self.embeddedPatternView.enableUserInputPathDrawing);
    
    [self updateEmbeddedPatternViewParameters];
    
    NSLog(@"New view parameters (%d / %d / %d)",
          self.embeddedPatternView.enableUserInput,
          self.embeddedPatternView.enablePatternReferenceInputPathDrawing,
          self.embeddedPatternView.enableUserInputPathDrawing);
}

// --------------------------------------------------------------
// NAVIGATION BAR UPDATE
// --------------------------------------------------------------

- (NSString*) getUpdatedNavigationBarTitle {
    // Should be overriden by sublcasses, if required
    return @"TO OVERRIDE";
}

- (void) updateNavigationBarTitleWith : (NSString*) newTitle {
    self.navigationItem.title = newTitle;
}

- (void) updateNavigationBarTitle {
    [self updateNavigationBarTitleWith : [self getUpdatedNavigationBarTitle]];
}


- (NSString*) getUpdatedNavigationBarPrompt {
    // Should be overriden by sublcasses
    return @"TO OVERRIDE";
}

- (void) updateNavigationBarPromptWith : (NSString*) newPrompt {
    self.navigationItem.prompt = newPrompt;
}

- (void) updateNavigationBarPrompt {
    [self updateNavigationBarPromptWith : [self getUpdatedNavigationBarPrompt]];
}


- (void) updateNavigationBar {
    [self updateNavigationBarTitle];
    [self updateNavigationBarPrompt];
}

// --------------------------------------------------------------
// ALERT POPUPS
// --------------------------------------------------------------

// Generic alert popup opener
- (void) openAlertWithTitle : (NSString*) title
                    message : (NSString*) message
                actionTitle : (NSString*) actionTitle
                     action : (void (^)(UIAlertAction * action)) action {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle : title
                                                                   message : message
                                                            preferredStyle : UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle : actionTitle
                                                            style : UIAlertActionStyleDefault
                                                          handler : action];
    
    [alert addAction:defaultAction];
    [self presentViewController : alert
                       animated : YES
                     completion : nil];
}

// --------------------------------------------------------------
// SEGUE CALLBACK
// --------------------------------------------------------------

// Generic preparation for moving from one step to another
// This method is meant to be called from specific, sublcass-to-subclass segues
- (void) prepareForGenericNextStep : (UIStoryboardSegue*) segue
                                   : (id) sender {
    StepViewController* nextStepViewController = segue.destinationViewController;
    
    // Set the reference session
    nextStepViewController.relatedSession = self.relatedSession;
    
    // Set the current pattern
    nextStepViewController.currentPattern = self.currentPattern;
    
    // Update internal steps
    [nextStepViewController updateCurrentSteps];
    
    NSLog(@"\n\n---------------------------------------------------- End of step %@ \n", self);
}

// Generic preparation for initializing the embedded view
- (void) prepareForEmbeddedPatternViewSegue : (UIStoryboardSegue*) segue
                                            : (id) sender {
    NSLog(@"PREPARE FOR EMBEDDED PATTERN VIEW SEGUE");
    
    // Get (and save) a reference to the embedded pattern view
    PatternViewController* embeddedPatternViewController = segue.destinationViewController;
    self.embeddedPatternView = (PatternView*) embeddedPatternViewController.view;

    // [self updateEmbeddedPatternView];
}

// Delegate each segue handling to different methods, one per segue identifier
- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender {
    if ([segue.identifier isEqualToString : @"EmbeddedPatternViewSegue"])
        [self prepareForEmbeddedPatternViewSegue : segue : sender];
}

@end
