//
//  UPFUnlockPatternReferenceInputs.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 20/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFPatternInput.h"
#import "UPFPatternInputSet.h"
#import "UPFPatternPath.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFPatternInputSet ()

// Internal array holding the inputs
@property NSMutableArray<UPFPatternInput*>* inputs;

@property (readwrite) unsigned int nbInputs;

@property (readwrite) int  maxNbInputs;
@property (readwrite) BOOL hasMaxNbInputs;

@property (readwrite) float averageForce;
@property (readwrite) float averageSpeed;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFPatternInputSet

// --------------------------------------------------------------
// INPUT SET ACCESS AND EDIT
// --------------------------------------------------------------

- (BOOL) isEmpty {
    return self.nbInputs == 0;
}

- (BOOL) hasFreeInputSlot {
    return self.nbInputs < self.maxNbInputs;
}

// Return the last input which has been added to this set; or nil if it does not exist (empty set)
- (UPFPatternInput*) getLastAddedInput {
    if ([self isEmpty])
        return nil;
    
    return (UPFPatternInput*) self.inputs[self.nbInputs - 1];
}

// A path is said to be acceptable in the only two follwoing cases:
// 1. the input set is empty
// 2. the path matches the path of the last added input

// Returns YES if (1) the given path match an already added input's path or (2) if the set is empty, NO otherwise
- (BOOL) pathIsAcceptable : (UPFPatternPath*) path {
    if ([self isEmpty])
        return YES;
    
    if (! self.checkForPathMatchingBeforeAddingInput)
        return YES;
    
    UPFPatternPath* referencePath = [self getLastAddedInput].patternPath;
    return [UPFPatternPath pathsAreEquivalent : referencePath : path];
}

// Add a valid input to the set
// Raises an exception 'UnmatchingPathsException' if the path is not acceptable
// Returns YES if the input has be added, NO otherwise (set is full)
- (BOOL) addInput : (UPFPatternInput*) input {
    // If there is no free slot, immediately return NO
    if (! [self hasFreeInputSlot])
        return NO;
    
    // If the path is not acceptable, raise an exception
    if (! [self pathIsAcceptable : input.patternPath]) {
        @throw [NSException exceptionWithName : @"UnmatchingPathsException"
                                       reason : @"Input paths do not match"
                                     userInfo : nil];
        return NO;
    }
    
    // Otherwise, add a copy of the input to the array
    [self.inputs addObject : [input copy]];
    self.nbInputs++;
    
    return YES;
}

// Remove the last added input from the set
// Returns YES if the input has be removedd, NO otherwise (set is empty)
- (BOOL) removeLastInput {
    if ([self isEmpty])
        return NO;
    
    [self.inputs removeLastObject];
    self.nbInputs--;
    
    return YES;
}

// Empty the whole input set
- (void) clear {
    [self.inputs removeAllObjects];
    self.nbInputs = 0;
    
    self.averageForce = 0;
    self.averageSpeed = 0;
}

// --------------------------------------------------------------
// META/STAT DATA
// --------------------------------------------------------------

- (void) computeStatisticalData {
    // TODO
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

- (NSString*) getInputDataFileNameForIndex : (unsigned int) index {
    return [NSString stringWithFormat : @"input-%d", index + 1];
}

- (void) exportDataInFolderAtPath : (NSString*) path {
    for (unsigned int i = 0; i < self.nbInputs; i++) {
        NSString*        currentInputFilename = [path stringByAppendingPathComponent : [self getInputDataFileNameForIndex : i]];
        UPFPatternInput* currentInput         = self.inputs[i];
        
        [currentInput exportDataInFileAtPath : currentInputFilename];
    }
}

// --------------------------------------------------------------
// BUILDERS
// --------------------------------------------------------------

+ (UPFPatternInputSet*) createEmptyInputSetOfSize : (int) maxNbInputs
                                checkPathMatching : (BOOL) checkForPathMatching {
    UPFPatternInputSet* newInputSet = [UPFPatternInputSet new];
    
    if (newInputSet) {
        newInputSet.inputs = [NSMutableArray<UPFPatternInput*> arrayWithCapacity : INPUT_SET_UNLIMITED_INPUTS == maxNbInputs
                                                                                 ? 8
                                                                                 : maxNbInputs];
        
        newInputSet.nbInputs = 0;
        
        newInputSet.maxNbInputs    = INPUT_SET_UNLIMITED_INPUTS == maxNbInputs
                                   ? INT_MAX
                                   : maxNbInputs;
        newInputSet.hasMaxNbInputs = INPUT_SET_UNLIMITED_INPUTS != maxNbInputs;
        
        newInputSet.checkForPathMatchingBeforeAddingInput = checkForPathMatching;
        
        newInputSet.averageForce = 0;
        newInputSet.averageSpeed = 0;

    }
    
    return newInputSet;
}

// By default, check for path matching
+ (UPFPatternInputSet*) createEmptyInputSetOfSize : (int) maxNbInputs {
    return [UPFPatternInputSet createEmptyInputSetOfSize : maxNbInputs
                                       checkPathMatching : NO];
}

// --------------------------------------------------------------
// COPYING
// --------------------------------------------------------------

- (id) copyWithZone : (NSZone *) zone {
    UPFPatternInputSet* inputSetCopy = [UPFPatternInputSet new];
    
    if (inputSetCopy) {
        inputSetCopy.inputs = [self.inputs copy];
        
        inputSetCopy.nbInputs    = self.nbInputs;
        
        inputSetCopy.maxNbInputs    = self.maxNbInputs;
        inputSetCopy.hasMaxNbInputs = self.hasMaxNbInputs;
        
        inputSetCopy.checkForPathMatchingBeforeAddingInput = self.checkForPathMatchingBeforeAddingInput;
        
        inputSetCopy.averageForce = self.averageForce;
        inputSetCopy.averageSpeed = self.averageSpeed;
    }
    
    return inputSetCopy;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.inputs                                forKey : @"inputs"];
    [aCoder encodeInt    : self.nbInputs                              forKey : @"nbInputs"];
    [aCoder encodeInt    : self.maxNbInputs                           forKey : @"maxNbInputs"];
    [aCoder encodeBool   : self.hasMaxNbInputs                        forKey : @"hasMaxNbInputs"];
    [aCoder encodeBool   : self.checkForPathMatchingBeforeAddingInput forKey : @"checkForPathMatchingBeforeAddingInput"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _inputs                                = [aDecoder decodeObjectForKey : @"inputs"];
        _nbInputs                              = [aDecoder decodeIntForKey    : @"nbInputs"];
        _maxNbInputs                           = [aDecoder decodeIntForKey    : @"maxNbInputs"];
        _hasMaxNbInputs                        = [aDecoder decodeBoolForKey   : @"hasMaxNbInputs"];
        _checkForPathMatchingBeforeAddingInput = [aDecoder decodeBoolForKey   : @"checkForPathMatchingBeforeAddingInput"];
    }
    
    return self;
}

@end
