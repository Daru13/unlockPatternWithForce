//
//  UPFUnlockPatternPathNode.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 16/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPatternNode.h"

@interface UPFPatternPathNode : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Actual unlock pattern node included in a path
@property (readonly) UPFPatternNode* relatedPatternNode;

// Metadata concerning the node activation
@property (readonly) unsigned int indexInPath;
@property (readonly) unsigned int selectionForce;
@property (readonly) double       selectionTimestamp;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

+ (UPFPatternPathNode*) createFromNode : (UPFPatternNode*) node
                                   atIndex   : (unsigned int) index
                                   withForce : (unsigned int) force
                                   atTime    : (double) timestamp;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
