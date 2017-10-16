//
//  UPFUnlockPatternNode.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPFPatternNode : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Position in the grid
@property (readonly) unsigned int row;
@property (readonly) unsigned int column;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

+ (UPFPatternNode*) createNodeAt : (unsigned int) row
                                 : (unsigned int) column;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
