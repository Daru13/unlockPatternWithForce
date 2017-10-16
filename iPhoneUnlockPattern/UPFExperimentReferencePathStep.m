//
//  UPFExperimentReferencePathStep.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 27/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFExperimentReferencePathStep.h"
#import "UPFPatternPath.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFExperimentReferencePathStep ()

@property (readwrite) UPFPatternPath* referencePath;

@property (readwrite) NSMutableArray<UPFExperimentUserInputStep*>* userInputSteps;

@property (readwrite) unsigned int nbUserInputStepsToPerform;
@property (readwrite) unsigned int nbUserInputStepsCompleted;
@property (readwrite) BOOL         isFinished;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFExperimentReferencePathStep

// --------------------------------------------------------------
// USER INPUT STEPS
// --------------------------------------------------------------

- (UPFExperimentUserInputStep*) getCurrentUserInputStep {
    return self.userInputSteps[self.nbUserInputStepsCompleted];
}

- (void) finishCurrentUserInputStep {
    self.nbUserInputStepsCompleted++;
    
    if (self.nbUserInputStepsToPerform == self.nbUserInputStepsCompleted)
        self.isFinished = YES;
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

- (NSString*) getUserInputStepFolderNameForIndex : (unsigned int) index {
    return [NSString stringWithFormat : @"user-input-step-%d", index + 1];
}

- (NSString*) getReferencePathFileName {
    return @"reference-path.txt";
}

- (void) exportDataInFolderAtPath : (NSString*) path {
    // Export the reference path data in a single file
    NSString* pathToReferencePathFile = [path stringByAppendingPathComponent : [self getReferencePathFileName]];
    [self.referencePath exportDataInFileAtPath : pathToReferencePathFile];
    
    // Export all user input steps data, one folder per step
    for (unsigned int i = 0; i < self.userInputSteps.count; i++) {
        UPFExperimentUserInputStep* currentUserInputStep = self.userInputSteps[i];
        NSString* pathToCurrentUserInputStepFolder = [path stringByAppendingPathComponent : [self getUserInputStepFolderNameForIndex : i]];
        
        [currentUserInputStep exportDataInFolderAtPath : pathToCurrentUserInputStepFolder];
    }
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method, for a given reference path
+ (UPFExperimentReferencePathStep*) createReferencePathStepFromPath : (UPFPatternPath*) path
                                                    nbForceProfiles : (unsigned int) requiredNbUserInputSteps
                                                       nbUserInputs : (unsigned int) requiredNbUserInputs {
    UPFExperimentReferencePathStep* newReferencePathStep = [UPFExperimentReferencePathStep new];
    
    if (newReferencePathStep) {
        newReferencePathStep.referencePath = path;
        
        // Create and fill an array of empty user input steps
        newReferencePathStep.userInputSteps = [NSMutableArray<UPFExperimentUserInputStep*> arrayWithCapacity : requiredNbUserInputSteps];
        for (unsigned int i = 0; i < requiredNbUserInputSteps; i++)
            newReferencePathStep.userInputSteps[i] = [UPFExperimentUserInputStep createUserInputStepRequiring : requiredNbUserInputs];
        
        newReferencePathStep.nbUserInputStepsToPerform = requiredNbUserInputSteps;
        newReferencePathStep.nbUserInputStepsCompleted = 0;
        newReferencePathStep.isFinished                = NO;
    }
    
    return newReferencePathStep;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.referencePath             forKey : @"referencePath"];
    [aCoder encodeObject : self.userInputSteps            forKey : @"userInputSteps"];
    [aCoder encodeInt    : self.nbUserInputStepsToPerform forKey : @"nbUserInputStepsToPerform"];
    [aCoder encodeInt    : self.nbUserInputStepsCompleted forKey : @"nbUserInputStepsCompleted"];
    [aCoder encodeBool   : self.isFinished                forKey : @"isFinished"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _referencePath              = [aDecoder decodeObjectForKey : @"referencePath"];
        _userInputSteps             = [aDecoder decodeObjectForKey : @"userInputSteps"];
        _nbUserInputStepsToPerform  = [aDecoder decodeIntForKey    : @"nbUserInputStepsToPerform"];
        _nbUserInputStepsCompleted  = [aDecoder decodeIntForKey    : @"nbUserInputStepsCompleted"];
        _isFinished                 = [aDecoder decodeBoolForKey   : @"isFinished"];
    }
    
    return self;
}


@end
