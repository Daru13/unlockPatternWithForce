//
//  UPFExperimentReferencePathStep.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 27/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFExperimentUserInputStep.h"
#import "UPFPatternPath.h"

@interface UPFExperimentReferencePathStep : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Path of reference for the user
@property (readonly) UPFPatternPath* referencePath;

// List of user input steps
@property (readonly) NSMutableArray<UPFExperimentUserInputStep*>* userInputSteps;

@property (readonly) unsigned int nbUserInputStepsToPerform;
@property (readonly) unsigned int nbUserInputStepsCompleted;
@property (readonly) BOOL         isFinished;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (UPFExperimentUserInputStep*) getCurrentUserInputStep;
- (void) finishCurrentUserInputStep;

- (void) exportDataInFolderAtPath : (NSString*) path;

+ (UPFExperimentReferencePathStep*) createReferencePathStepFromPath : (UPFPatternPath*) path
                                                    nbForceProfiles : (unsigned int) requiredNbUserInputSteps
                                                       nbUserInputs : (unsigned int) requiredNbUserInputs;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
