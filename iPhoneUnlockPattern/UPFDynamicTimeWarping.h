//
//  UPFDynamicTimeWarping2.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 22/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFInputMatchingAlgorithm.h"
#import "UPFPattern.h"
#import "UPFPatternInput.h"

@interface UPFDynamicTimeWarping : NSObject <UPFInputMatchingAlgorithm>

+ (float) getMatchingScoreOfInput : (UPFPatternInput*) input
                      withPattern : (UPFPattern*)      pattern;

+ (BOOL) isInputMatching : (UPFPatternInput*) input
             withPattern : (UPFPattern*)      pattern;

@end
