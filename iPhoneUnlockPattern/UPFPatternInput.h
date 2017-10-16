//
//  UPFUnlockPatternInput.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 19/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPatternPath.h"
#import "UPFTouchEventLog.h"

@interface UPFPatternInput : NSObject <NSCopying, NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// An input represents all the required information to differentiate a reference pattern input from a given one
// It thus includes: a pattern path and a touch event log (for force profiling)
@property UPFPatternPath*   patternPath;
@property UPFTouchEventLog* touchEventLog;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) clear;

+ (BOOL) inputsAreEquivalent : (UPFPatternInput*) input1
                             : (UPFPatternInput*) input2;

- (void) exportDataInFileAtPath : (NSString*) path;

+ (UPFPatternInput*) createFromPatternPath : (UPFPatternPath*) patternPath
                             touchEventLog : (UPFTouchEventLog*)  touchEventLog;
+ (UPFPatternInput*) createEmptyInput;

- (id) copyWithZone : (NSZone *) zone;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
