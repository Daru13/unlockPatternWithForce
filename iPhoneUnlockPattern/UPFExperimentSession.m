//
//  UPFExperimentSession.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 23/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFExperimentConstants.h"
#import "UPFExperimentSession.h"
#import "UPFExperiment.h"
#import "UPFExperimentUser.h"
#import "UPFExperimentReferencePathStep.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFExperimentSession ()

@property (readwrite) unsigned int number;
@property (readwrite) UPFUserId    userId;

@property (copy, readwrite) NSArray<UPFExperimentReferencePathStep*>* referencePathSteps;

@property (readwrite) UPFPatternInputSet* trainingInputSet;

@property (readwrite) unsigned int nbPathStepsToPerform;
@property (readwrite) unsigned int nbPathStepsCompleted;
@property (readwrite) BOOL         isFinished;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFExperimentSession

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

- (void) initListOfPathSteps {
    NSMutableArray<UPFExperimentReferencePathStep*>* referencePathSteps = [NSMutableArray<UPFExperimentReferencePathStep*> array];
    
    // Loop over the list of experiment reference paths, and make a ref. path step for each of them
    NSArray<UPFPatternPath*>* referencePaths = [UPFExperiment listOfReferencePaths];
    
    for (unsigned int i = 0; i < referencePaths.count; i++) {
        UPFExperimentReferencePathStep* currentReferencePathStep =
        [UPFExperimentReferencePathStep createReferencePathStepFromPath : referencePaths[i]
                                                        nbForceProfiles : EXPERIMENT_NB_FORCE_PROFILES
                                                           nbUserInputs : EXPERIMENT_NB_USER_INPUTS];
        [referencePathSteps addObject : currentReferencePathStep];
    }
    
    // Mutable array is a subtype of array
    // Thus, casting it makes it loose its 'edit properties', and fit the property's type
    self.referencePathSteps = (NSArray<UPFExperimentReferencePathStep*>*) referencePathSteps;

    NSLog(@"Session has been init with list of path steps: %@ (length: %d)",
          self.referencePathSteps, (int) self.referencePathSteps.count);
}

// Init the session so it can be used as a fresh object for starting an experiment with it
- (void) initAsFreshSession {
    // Initialize the path steps from the ref. paths
    [self initListOfPathSteps];
    
    // Create an empty input set for training inputs
    self.trainingInputSet = [UPFPatternInputSet createEmptyInputSetOfSize : INPUT_SET_UNLIMITED_INPUTS
                                                        checkPathMatching : NO];
    
    // Set values so as the session has not been started yet
    self.nbPathStepsToPerform = (unsigned int) self.referencePathSteps.count;
    self.nbPathStepsCompleted = 0;
    self.isFinished           = NO;
}

// --------------------------------------------------------------
// SESSION-RELATED TYPES AS STRINGS
// --------------------------------------------------------------

+ (NSString*) inputModeAsString : (UPFSessionInputMode) inputMode {
    switch (inputMode) {
        case SESSION_INPUT_MODE_SINGLE_HAND:
            return @"Single hand input";
        case SESSION_INPUT_MODE_TWO_HANDS:
            return @"Two hands input";
        case SESSION_INPUT_MODE_TABLETOP:
            return @"Tabletop input";
        default:
            return @"Unknown input mode";
    }
}

+ (NSString*) stepsOrderAsString : (UPFSessionStepsOrder) stepsOrder {
    switch (stepsOrder) {
        case SESSION_STEPS_ORDER_NORMAL:
            return @"Normal steps order";
        case SESSION_STEPS_ORDER_SHUFFLED:
            return @"Shuffled steps order";
        default:
            return @"Unknown steps order";
    }
}

// --------------------------------------------------------------
// PATH STEPS
// --------------------------------------------------------------

- (UPFExperimentReferencePathStep*) getCurrentReferencePathStep {
    NSLog(@"Get cur path step %@ from %@ at index %d",
          self.referencePathSteps[self.nbPathStepsCompleted], self.referencePathSteps, self.nbPathStepsCompleted);
    return self.referencePathSteps[self.nbPathStepsCompleted];
}

- (void) finishCurrentPathStep {
    self.nbPathStepsCompleted++;
    
    if (self.nbPathStepsCompleted == self.nbPathStepsToPerform)
        self.isFinished = YES;
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

- (NSString*) getTrainingInputsFolderName {
    return @"training-inputs";
}

- (NSString*) getReferencePathStepFolderNameForIndex : (unsigned int) index {
    return [NSString stringWithFormat : @"reference-path-step-%d", index + 1];
}

- (void) exportDataInFolderAtPath : (NSString*) path {
    // Export the training input set in a single folder
    NSString* pathToTrainingInputsFolder = [path stringByAppendingPathComponent : [self getTrainingInputsFolderName]];
    [self.trainingInputSet exportDataInFolderAtPath : pathToTrainingInputsFolder];
    
    // Export all reference path steps data, one folder per step
    for (unsigned int i = 0; i < self.referencePathSteps.count; i++) {
        UPFExperimentReferencePathStep* currentReferencePathStep = self.referencePathSteps[i];
        NSString* pathToCurrentReferencePathStepFolder = [path stringByAppendingPathComponent : [self getReferencePathStepFolderNameForIndex : i]];
        
        [currentReferencePathStep exportDataInFolderAtPath : pathToCurrentReferencePathStepFolder];
    }
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method, for a given session number and related user ID
// The latter tuple should be different for all previously created session — but this is not tested here!
+ (UPFExperimentSession*) createSessionWithNumber : (unsigned int) number
                                           userId : (UPFUserId) userId
                                    mainInputMode : (UPFSessionInputMode) inputMode {
    UPFExperimentSession* newSession = [UPFExperimentSession new];
    
    if (newSession) {
        // Init the new session as a 'fresh' one
        [newSession initAsFreshSession];
        
        // Set session parameters
        newSession.number        = number;
        newSession.userId        = userId;
        newSession.mainInputMode = inputMode;
        
        // By default, patterns are presented in random order to the user
        newSession.stepsOrder = SESSION_STEPS_ORDER_SHUFFLED;
        
        // Change the steps order if required by a session parameter
        // TODO
    }
    
    return newSession;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeInt    : self.number                               forKey : @"number"];
    [aCoder encodeObject : [NSNumber numberWithDouble : self.userId] forKey : @"userId"];
    [aCoder encodeInt    : self.mainInputMode                        forKey : @"mainInputMode"];
    [aCoder encodeInt    : self.stepsOrder                           forKey : @"stepsOrder"];
    [aCoder encodeObject : self.referencePathSteps                   forKey : @"referencePathSteps"];
    [aCoder encodeObject : self.trainingInputSet                     forKey : @"trainingInputSet"];
    [aCoder encodeInt    : self.nbPathStepsToPerform                 forKey : @"nbPathStepsToPerform"];
    [aCoder encodeInt    : self.nbPathStepsCompleted                 forKey : @"nbPathStepsCompleted"];
    [aCoder encodeBool   : self.isFinished                           forKey : @"isFinished"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _number               = [aDecoder decodeIntForKey     : @"number"];
        _userId               = [[aDecoder decodeObjectForKey : @"userId"] longValue];
        _mainInputMode        = [aDecoder decodeIntForKey     : @"mainInputMode"];
        _stepsOrder           = [aDecoder decodeIntForKey     : @"stepsOrder"];
        _referencePathSteps   = [aDecoder decodeObjectForKey  : @"referencePathSteps"];
        _trainingInputSet     = [aDecoder decodeObjectForKey  : @"trainingInputSet"];
        _nbPathStepsToPerform = [aDecoder decodeIntForKey     : @"nbPathStepsToPerform"];
        _nbPathStepsCompleted = [aDecoder decodeIntForKey     : @"nbPathStepsCompleted"];
        _isFinished           = [aDecoder decodeBoolForKey    : @"isFinished"];
    }
    
    return self;
}

@end
