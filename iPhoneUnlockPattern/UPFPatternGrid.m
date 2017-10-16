//
//  UPFUnlockPatternGrid.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFPatternNode.h"
#import "UPFPatternGrid.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFPatternGrid ()

@property (readwrite) unsigned int nbRows;
@property (readwrite) unsigned int nbColumns;

// Internal repreentation of the matrix of cells
@property NSArray* cells;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFPatternGrid

// --------------------------------------------------------------
// MATRIX-LIKE ACCESS TO CELLS (NODES)
// --------------------------------------------------------------

// Matrix-like getter for the grid cells
- (unsigned int) arrayIndexFromMatrixCoords : (unsigned int) row
                                            : (unsigned int) column {
    return (self.nbColumns * row) + column;
}

- (UPFPatternNode*) getCellAt : (unsigned int) row
                              : (unsigned int) column {
    unsigned int cellIndexInArray = [self arrayIndexFromMatrixCoords : row : column];
    return self.cells[cellIndexInArray];
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method, for given dimensions
+ (UPFPatternGrid*) createGridOfSize : (unsigned int) nbRows
                                           : (unsigned int) nbColumns {
    UPFPatternGrid* newGrid = [UPFPatternGrid new];
    if (newGrid) {
        newGrid.nbRows    = nbRows;
        newGrid.nbColumns = nbColumns;
        
        newGrid.cells = [NSArray new];
        for (int row = 0; row < nbRows; row++) {
            for (int column = 0; column < nbColumns; column++) {
                UPFPatternNode* newNode = [UPFPatternNode createNodeAt : row : column];
                newGrid.cells = [newGrid.cells arrayByAddingObject : newNode];
            }
        }
        
    }
    
    return newGrid;
}

// --------------------------------------------------------------
// FAST ITERATOR
// --------------------------------------------------------------

// Fast iteration over the grid cells is done by 'proxying' the (internal) cell NSArray fast iterator
- (NSUInteger) countByEnumeratingWithState : (NSFastEnumerationState*) state
                                   objects : (id __unsafe_unretained *) buffer
                                     count : (NSUInteger) length {
    return [self.cells countByEnumeratingWithState:state objects:buffer count:length];
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.cells     forKey : @"cells"];
    [aCoder encodeInt    : self.nbRows    forKey : @"nbRows"];
    [aCoder encodeInt    : self.nbColumns forKey : @"nbColumns"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _cells     = [aDecoder decodeObjectForKey : @"cells"];
        _nbRows    = [aDecoder decodeIntForKey    : @"nbRows"];
        _nbColumns = [aDecoder decodeIntForKey    : @"NbColumns"];
    }
    
    return self;
}

@end
