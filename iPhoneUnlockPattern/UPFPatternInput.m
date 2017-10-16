//
//  UPFUnlockPatternInput.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 19/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFPatternInput.h"
#import "UPFPatternPath.h"
#import "UPFTouchEventLog.h"

@implementation UPFPatternInput

// --------------------------------------------------------------
// INPUT EDIT
// --------------------------------------------------------------

// Clear all the structures holding input information
- (void) clear {
    [self.patternPath clear];
    [self.touchEventLog clear];
}

// --------------------------------------------------------------
// INPUTS COMPARISON
// --------------------------------------------------------------

+ (BOOL) inputsAreEquivalent : (UPFPatternInput*) input1
                             : (UPFPatternInput*) input2 {
    // TODO: improve and implement algoirhtms here
    return [UPFPatternPath pathsAreEquivalent : input1.patternPath : input2.patternPath];
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

- (void) exportDataInFileAtPath : (NSString*) path {
    // Only export the logged touch event data
    [self.touchEventLog exportDataInFileAtPath : path];
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

+ (UPFPatternInput*) createFromPatternPath : (UPFPatternPath*) patternPath
                             touchEventLog : (UPFTouchEventLog*)  touchEventLog {
    UPFPatternInput* newPatternInput = [UPFPatternInput new];
    
    if (newPatternInput) {
        newPatternInput.patternPath   = patternPath;
        newPatternInput.touchEventLog = touchEventLog;
    }
    
    return newPatternInput;
}

+ (UPFPatternInput*) createEmptyInput {
    return [UPFPatternInput createFromPatternPath : [UPFPatternPath createEmptyPath]
                                    touchEventLog : [UPFTouchEventLog createEmptyLog : @""]];
}

// --------------------------------------------------------------
// COPYING
// --------------------------------------------------------------

- (id) copyWithZone : (NSZone *) zone {
    UPFPatternInput* inputCopy = [UPFPatternInput new];
    
    if (inputCopy) {
        inputCopy.patternPath   = [self.patternPath copy];
        inputCopy.touchEventLog = [self.touchEventLog copy];
    }
    
    return inputCopy;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.patternPath   forKey : @"patternPath"];
    [aCoder encodeObject : self.touchEventLog forKey : @"touchEventLog"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _patternPath   = [aDecoder decodeObjectForKey : @"patternPath"];
        _touchEventLog = [aDecoder decodeObjectForKey : @"touchEventLog"];
    }
    
    return self;
}

@end
