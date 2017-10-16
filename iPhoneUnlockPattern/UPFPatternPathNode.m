//
//  UPFUnlockPatternPathNode.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 16/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFPatternPathNode.h"
#import "UPFPatternNode.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFPatternPathNode ()

@property (readwrite) UPFPatternNode* relatedPatternNode;

@property (readwrite) unsigned int indexInPath;
@property (readwrite) unsigned int selectionForce;
@property (readwrite) double       selectionTimestamp;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFPatternPathNode

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method, for a given reference node and required metadata
+ (UPFPatternPathNode*) createFromNode : (UPFPatternNode*) node
                               atIndex   : (unsigned int) index
                               withForce : (unsigned int) force
                               atTime    : (double) timestamp {
    UPFPatternPathNode* newPathNode = [UPFPatternPathNode new];
    
    if (newPathNode) {
        newPathNode.relatedPatternNode = node;
        newPathNode.indexInPath        = index;
        newPathNode.selectionForce     = force;
        newPathNode.selectionTimestamp = timestamp;
    }
    
    return newPathNode;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.relatedPatternNode forKey : @"relatedPatternNode"];
    [aCoder encodeInt    : self.indexInPath        forKey : @"indexInPath"];
    [aCoder encodeInt    : self.selectionForce     forKey : @"selectionForce"];
    [aCoder encodeDouble : self.selectionTimestamp forKey : @"selectionTimestamp"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _relatedPatternNode = [aDecoder decodeObjectForKey : @"relatedPatternNode"];
        _indexInPath        = [aDecoder decodeIntForKey    : @"indexInPath"];
        _selectionForce     = [aDecoder decodeIntForKey    : @"selectionForce"];
        _selectionTimestamp = [aDecoder decodeDoubleForKey : @"selectionTimestamp"];
    }
    
    return self;
}

@end
