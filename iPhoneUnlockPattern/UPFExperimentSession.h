//
//  UPFExperimentSession.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 23/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFExperimentUser.h"
#import "UPFExperimentReferencePathStep.h"
#import "UPFPatternInputSet.h"

// Enumerated type for session-wise experimental conditions
typedef enum {
    SESSION_INPUT_MODE_SINGLE_HAND,
    SESSION_INPUT_MODE_TWO_HANDS,
    SESSION_INPUT_MODE_TABLETOP
} UPFSessionInputMode;

typedef enum {
    SESSION_STEPS_ORDER_NORMAL,
    SESSION_STEPS_ORDER_SHUFFLED
} UPFSessionStepsOrder;


@interface UPFExperimentSession : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Session number and related user id
@property (readonly) unsigned int number;
@property (readonly) UPFUserId    userId;

// Related session information
@property UPFSessionInputMode  mainInputMode;
@property UPFSessionStepsOrder stepsOrder;

// List of reference path steps
@property (readonly) NSArray<UPFExperimentReferencePathStep*>* referencePathSteps;

// Set of user inputs saved during training
@property (readonly) UPFPatternInputSet* trainingInputSet;

// Session state
@property (readonly) unsigned int nbPathStepsToPerform;
@property (readonly) unsigned int nbPathStepsCompleted;
@property (readonly) BOOL         isFinished;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

+ (NSString*) inputModeAsString : (UPFSessionInputMode) inputMode;
+ (NSString*) stepsOrderAsString : (UPFSessionStepsOrder) stepsOrder;

- (UPFExperimentReferencePathStep*) getCurrentReferencePathStep;
- (void) finishCurrentPathStep;

- (void) exportDataInFolderAtPath : (NSString*) path;

+ (UPFExperimentSession*) createSessionWithNumber : (unsigned int) number
                                           userId : (UPFUserId) userId
                                    mainInputMode : (UPFSessionInputMode) inputMode;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
