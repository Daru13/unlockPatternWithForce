//
//  UPFDynamicTimeWarping.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 21/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFInputMatchingAlgorithm.h"
#import "UPFPattern.h"
#import "UPFPatternInput.h"

@interface UPFDerivativeDynamicTimeWarping : NSObject <UPFInputMatchingAlgorithm>

+ (float) getMatchingScoreOfInput : (UPFPatternInput*) input
                      withPattern : (UPFPattern*)      pattern;

+ (BOOL) isInputMatching : (UPFPatternInput*) input
             withPattern : (UPFPattern*)      pattern;

@end
