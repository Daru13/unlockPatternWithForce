//
//  UPFUnlockPattern.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPatternGrid.h"
#import "UPFPatternInputSet.h"

@interface UPFPattern : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

@property (readonly) UPFPatternGrid* nodeGrid;

// Reference input set for unlocking
// Note: it may be undefined (set to nil), if no solution has been set yet
@property (copy) UPFPatternInputSet* referenceInputSet;


// --------------------------------------------------------------
// STATIC PROPERTIES
// --------------------------------------------------------------

// Class-level unlock pattern singleton
+ (instancetype) sharedPattern;


// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (BOOL) referenceInputSetIsDefined;

- (BOOL) matchesWithInput : (UPFPatternInput*) input;

+ (UPFPattern*) createPatternOfSize : (unsigned int) nbRows
                                    : (unsigned int) nbColumns;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
