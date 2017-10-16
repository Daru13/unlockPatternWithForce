//
//  UPFUnlockPattern.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFPatternGrid.h"
#import "UPFPatternInputSet.h"
#import "UPFPattern.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFPattern ()

@property (readwrite) UPFPatternGrid* nodeGrid;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFPattern

// --------------------------------------------------------------
// SINGLETON PATTERN (ACCESS + CREATION)
// --------------------------------------------------------------

// Created as a 3x3 pattern for now
+ (instancetype) sharedPattern {
    static UPFPattern* globalPatternInstance = nil;
    static dispatch_once_t   singleInitToken;
    
    dispatch_once(&singleInitToken, ^{
        globalPatternInstance = [UPFPattern createPatternOfSize : 3 : 3];
        NSLog(@"Global UP created: %@", globalPatternInstance);
    });
    
    NSLog(@"globalPatternInstance access: %@", globalPatternInstance);
    return globalPatternInstance;
}

// --------------------------------------------------------------
// SOLUTION PATH TESTING
// --------------------------------------------------------------

// TODO: use algorithms, sets...

// Returns YES if a solution path is defined; NO otherwise
- (BOOL) referenceInputSetIsDefined {
    return self.referenceInputSet != nil;
}

// Returns YES if the given input match to the reference input set; NO otherwise
- (BOOL) matchesWithInput : (UPFPatternInput*) input {
    if (! [self referenceInputSetIsDefined])
        return NO;
    
    if ([self.referenceInputSet isEmpty])
        return NO;
    
    return [UPFPatternInput inputsAreEquivalent : input
                                                : [self.referenceInputSet getLastAddedInput]];
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method, for a given pattern dimensions
+ (UPFPattern*) createPatternOfSize : (unsigned int) nbRows
                                    : (unsigned int) nbColumns {
    UPFPattern* newPattern = [UPFPattern new];
    if (newPattern) {
        newPattern.nodeGrid = [UPFPatternGrid createGridOfSize : nbRows
                                                               : nbColumns];
        newPattern.referenceInputSet = nil;
    }
    
    return newPattern;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.nodeGrid          forKey : @"nodeGrid"];
    [aCoder encodeObject : self.referenceInputSet forKey : @"referenceInputSet"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _nodeGrid          = [aDecoder decodeObjectForKey : @"nodeGrid"];
        _referenceInputSet = [aDecoder decodeObjectForKey : @"referenceInputSet"];
    }
    
    return self;
}

@end
