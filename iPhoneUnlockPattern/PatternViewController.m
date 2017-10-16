//
//  UnlockPatternViewController.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "PatternViewController.h"
#import "PatternView.h"
#import "UPFPattern.h"

#import "UPFExperiment.h"

@implementation PatternViewController

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

- (void) initPropertiesWithDefaultValues {
    
}

// --------------------------------------------------------------
// VIEW LIFECYCLE CALLBACKS
// --------------------------------------------------------------

// The view has been loaded
- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    [self initPropertiesWithDefaultValues];
}

// The view has been displayed
- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : animated];
    
    NSLog(@"(Pattern view appearing)");
    
    // Start the view's timers
    PatternView* view = (PatternView*) self.view;
    
    [view startRegularGraphicalUpdate];
    [view startRegularMultitouchEventProcessing];
}

// The view has been hidden
- (void) viewWillDisappear : (BOOL) animated {
    [super viewWillDisappear : animated];
    
    NSLog(@"(Pattern view disappearing)");
    
    // Stop the view's timers
    PatternView* view = (PatternView*) self.view;
    
    [view stopRegularGraphicalUpdate];
    [view stopRegularMultitouchEventProcessing];
}

@end
