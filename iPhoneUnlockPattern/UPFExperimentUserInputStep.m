//
//  UPFExperimentUserInputStep.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 27/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFExperimentUserInputStep.h"
#import "UPFPatternInputSet.h"
#import "UPFPatternInput.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFExperimentUserInputStep ()

@property (readwrite) UPFPatternInputSet* singleHandInputSet;
@property (readwrite) UPFPatternInputSet* twoHandsInputSet;

@property (readwrite) unsigned int requiredNbInputsWithSingleHand;
@property (readwrite) unsigned int requiredNbInputsWithTwoHands;

@property (readwrite) UPFUserInputStepState state;
@property (readwrite) UPFUserInputSubstep   substep;
@property (readwrite) BOOL                  isFinished;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFExperimentUserInputStep

// --------------------------------------------------------------
// STATES
// --------------------------------------------------------------

- (void) startDisplayReferencePathMode {
    if (self.state != USER_INPUT_STEP_STATE_TRAINING)
        NSLog(@"WARNING: startDisplayReferencePathMode called, but %@ is not in training mode!", self);
    
    self.state = USER_INPUT_STEP_STATE_DISPLAY_REFERENCE_PATH;
}

- (void) startForceProfileInputMode {
    if (self.state != USER_INPUT_STEP_STATE_DISPLAY_REFERENCE_PATH)
        NSLog(@"WARNING: startForceProfileInputMode called, but %@ is not in display ref. input mode!", self);
    
    self.state = USER_INPUT_STEP_STATE_FORCE_PROFILE_INPUT;
}

- (void) startUserInputMode {
    if (self.state != USER_INPUT_STEP_STATE_FORCE_PROFILE_INPUT)
        NSLog(@"WARNING: startInputMode called, but %@ is not in training mode!", self);
    
    self.state = USER_INPUT_STEP_STATE_USER_INPUTS;
}

// --------------------------------------------------------------
// SUBSTEPS
// --------------------------------------------------------------

- (void) updateSubstepWith : (UPFUserInputSubstep) substep {
    NSLog(@"Substep of %@ changed to %d", self, substep);
    
    self.substep = substep;
    
    if (substep == USER_INPUT_SUBSTEP_ENDED)
        self.isFinished = YES;
    else
        self.isFinished = NO;
}

// Return the input set associated with a given substep, or nil if there is none
- (UPFPatternInputSet*) getInputSetRelatedToSubtep : (UPFUserInputSubstep) substep {
    switch (substep) {
        case USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT:
            return self.singleHandInputSet;
            
        case USER_INPUT_SUBSTEP_TWO_HANDS_INPUT:
            return self.twoHandsInputSet;
        
        default:
        case USER_INPUT_SUBSTEP_NOT_STARTED:
        case USER_INPUT_SUBSTEP_ENDED:
            return nil;
    }
}

- (UPFPatternInputSet*) getInputSetRelatedToCurrentSubtep {
    return [self getInputSetRelatedToSubtep : self.substep];
}

// Return the number of required inputs for the input set related to the given substep, or 0 if there is none
- (unsigned int) getNbRequiredInputsRelatedToSubstep : (UPFUserInputSubstep) substep {
    switch (substep) {
        case USER_INPUT_SUBSTEP_SINGLE_HAND_INPUT:
            return self.requiredNbInputsWithSingleHand;
            
        case USER_INPUT_SUBSTEP_TWO_HANDS_INPUT:
            return self.requiredNbInputsWithTwoHands;
            
        default:
        case USER_INPUT_SUBSTEP_NOT_STARTED:
        case USER_INPUT_SUBSTEP_ENDED:
            return 0;
    }
}

- (unsigned int) getNbRequiredInputsRelatedToCurrentSubstep {
    return [self getNbRequiredInputsRelatedToSubstep : self.substep];
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

- (NSString*) getForceProfileFolderName {
    return @"force-profile";
}

- (NSString*) getSingleHandInputsFolderName {
    return @"single-hand-inputs";
}

- (NSString*) getTwoHandsInputsFolderName {
    return @"two-hands-inputs";
}

- (NSString*) getValidInputsSubfolderName {
    return @"valid-inputs";
}

- (NSString*) getErroneousInputsSubfolderName {
    return @"erroneous-inputs";
}

- (void) exportForceProfileDataInFolderAtPath : (NSString*) path {
    NSString* pathToForceProfileFolder = [path stringByAppendingPathComponent : [self getForceProfileFolderName]];
    
    NSString* pathToValidForceProfileInputs = [pathToForceProfileFolder stringByAppendingPathComponent : [self getValidInputsSubfolderName]];
    [self.forceProfileInputs exportDataInFolderAtPath : pathToValidForceProfileInputs];
    
    NSString* pathToErroneousForceProfileInputs = [pathToForceProfileFolder stringByAppendingPathComponent : [self getErroneousInputsSubfolderName]];
    [self.forceProfileErroneousInputs exportDataInFolderAtPath : pathToErroneousForceProfileInputs];
}

- (void) exportSingleHandDataInFolderAtPath : (NSString*) path {
    NSString* pathToSingleHandInputsFolder = [path stringByAppendingPathComponent : [self getSingleHandInputsFolderName]];
    
    NSString* pathToValidSingleHandInputs = [pathToSingleHandInputsFolder stringByAppendingPathComponent : [self getValidInputsSubfolderName]];
    [self.singleHandInputSet exportDataInFolderAtPath : pathToValidSingleHandInputs];
    
    NSString* pathToErroneousSingleHandInputs = [pathToSingleHandInputsFolder stringByAppendingPathComponent : [self getErroneousInputsSubfolderName]];
    [self.singleHandErroneousInputs exportDataInFolderAtPath : pathToErroneousSingleHandInputs];
}

- (void) exportTwoHandsDataInFolderAtPath : (NSString*) path {
    NSString* pathToTwoHandsInputsFolder = [path stringByAppendingPathComponent : [self getTwoHandsInputsFolderName]];
    
    NSString* pathToValidTwoHandsInputs = [pathToTwoHandsInputsFolder stringByAppendingPathComponent : [self getValidInputsSubfolderName]];
    [self.twoHandsInputSet exportDataInFolderAtPath : pathToValidTwoHandsInputs];
    
    NSString* pathToErroneousTwoHandsInputs = [pathToTwoHandsInputsFolder stringByAppendingPathComponent : [self getErroneousInputsSubfolderName]];
    [self.twoHandsErroneousInputs exportDataInFolderAtPath : pathToErroneousTwoHandsInputs];
}

- (void) exportDataInFolderAtPath : (NSString*) path {
    [self exportForceProfileDataInFolderAtPath : path];
    [self exportSingleHandDataInFolderAtPath   : path];
    [self exportTwoHandsDataInFolderAtPath     : path];
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method for a given required number of inputs
+ (UPFExperimentUserInputStep*) createUserInputStepRequiring : (unsigned int) requiredNbInputs {
    UPFExperimentUserInputStep* newUserInputStep = [UPFExperimentUserInputStep new];
    
    if (newUserInputStep) {
        // Set the — currently undefined — reference input to nil
        newUserInputStep.forceProfileInputs = nil;
        
        // Create empty input sets for to-be-recorded pattern inputs
        newUserInputStep.singleHandInputSet = [UPFPatternInputSet createEmptyInputSetOfSize : requiredNbInputs];
        newUserInputStep.twoHandsInputSet   = [UPFPatternInputSet createEmptyInputSetOfSize : requiredNbInputs];
        
        newUserInputStep.requiredNbInputsWithSingleHand = requiredNbInputs;
        newUserInputStep.requiredNbInputsWithTwoHands   = requiredNbInputs;
        
        // The step starts in display reference input mode, and in the 'not started' mode
        newUserInputStep.state      = USER_INPUT_STEP_STATE_TRAINING;
        newUserInputStep.substep    = USER_INPUT_SUBSTEP_NOT_STARTED;
        newUserInputStep.isFinished = NO;
    }
    
    return newUserInputStep;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.forceProfileInputs             forKey : @"forceProfileInputs"];
    [aCoder encodeObject : self.singleHandInputSet             forKey : @"singleHandInputSet"];
    [aCoder encodeObject : self.twoHandsInputSet               forKey : @"twoHandsInputSet"];
    [aCoder encodeInt    : self.requiredNbInputsWithSingleHand forKey : @"requiredNbInputsWithSingleHand"];
    [aCoder encodeInt    : self.requiredNbInputsWithTwoHands   forKey : @"requiredNbInputsWithTwoHands"];
    [aCoder encodeInt    : self.state                          forKey : @"state"];
    [aCoder encodeInt    : self.substep                        forKey : @"substep"];
    [aCoder encodeBool   : self.isFinished                     forKey : @"isFinished"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _forceProfileInputs              = [aDecoder decodeObjectForKey : @"forceProfileInputs"];
        _singleHandInputSet              = [aDecoder decodeObjectForKey : @"singleHandInputSet"];
        _twoHandsInputSet                = [aDecoder decodeObjectForKey : @"twoHandsInputSet"];
        _requiredNbInputsWithSingleHand  = [aDecoder decodeIntForKey    : @"requiredNbInputsWithSingleHand"];
        _requiredNbInputsWithTwoHands    = [aDecoder decodeIntForKey    : @"requiredNbInputsWithTwoHands"];
        _state                           = [aDecoder decodeIntForKey    : @"state"];
        _substep                         = [aDecoder decodeIntForKey    : @"substep"];
        _isFinished                      = [aDecoder decodeBoolForKey   : @"isFinished"];
    }
    
    return self;
}

@end
