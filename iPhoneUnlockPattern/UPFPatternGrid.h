//
//  UPFUnlockPatternGrid.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPatternNode.h"

// Note: the grid content is handled internally, as there is no native Object-matrix support
@interface UPFPatternGrid : NSObject <NSFastEnumeration, NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Grid size
@property (readonly) unsigned int nbRows;
@property (readonly) unsigned int nbColumns;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (UPFPatternNode* _Nonnull) getCellAt : (unsigned int) row
                                       : (unsigned int) column;

+ (UPFPatternGrid*_Nonnull) createGridOfSize : (unsigned int) nbRows
                                     : (unsigned int) nbColumns;

- (NSUInteger) countByEnumeratingWithState : (NSFastEnumerationState*_Nullable) state
                                   objects : (id _Nullable __unsafe_unretained *_Nullable) buffer
                                     count : (NSUInteger) length;

- (void) encodeWithCoder : (NSCoder*_Nonnull) aCoder;
- (instancetype _Nonnull ) initWithCoder : (NSCoder*_Nonnull) aDecoder;

@end
