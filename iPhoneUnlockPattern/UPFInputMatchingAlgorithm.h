//
//  UPFInputMatchingAlgorithm.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 20/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPattern.h"
#import "UPFPatternInput.h"

@protocol UPFInputMatchingAlgorithm <NSObject>

@required

// This methods must returns a matching score for given input and pattern
// A matching score is a floating point value ranging between 0.0 (no match) and 1.0 (perfect match),
// which indicates how close to a reference the given input is
+ (float) getMatchingScoreOfInput : (UPFPatternInput*) input
                      withPattern : (UPFPattern*)      pattern;

// This method must return YES if the given input matches with the givent pattern, and NO otherwise
// It is recommended to use the matching score (defined above), with a threshold bewteen matching success and failure
+ (BOOL) isInputMatching : (UPFPatternInput*) input
             withPattern : (UPFPattern*)      pattern;

@end
