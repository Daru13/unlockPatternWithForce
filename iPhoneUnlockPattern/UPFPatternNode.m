//
//  UPFUnlockPatternNode.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFPatternNode.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFPatternNode ()

@property (readwrite) unsigned int row;
@property (readwrite) unsigned int column;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFPatternNode

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method, for a given position in a grid
+ (UPFPatternNode*) createNodeAt : (unsigned int) row
                                 : (unsigned int) column {
    UPFPatternNode* newNode = [UPFPatternNode new];
    if (newNode) {
        newNode.row    = row;
        newNode.column = column;
    }
    
    return newNode;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeInt : self.row    forKey : @"row"];
    [aCoder encodeInt : self.column forKey : @"column"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _row    = [aDecoder decodeIntForKey : @"row"];
        _column = [aDecoder decodeIntForKey : @"column"];
    }
    
    return self;
}

@end
