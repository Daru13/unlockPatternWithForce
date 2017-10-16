//
//  UPFUnlockPatternReferenceInputs.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 20/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPatternInput.h"

// Constant which should be used to create an input set with no size limit
#define INPUT_SET_UNLIMITED_INPUTS -1

@interface UPFPatternInputSet : NSObject <NSCopying, NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

@property (readonly) unsigned int nbInputs;

// Optionnal, maximum number of inputs
@property (readonly) int maxNbInputs;
@property (readonly) BOOL hasMaxNbInputs;

// Check for path consistency accros added patterns
@property BOOL checkForPathMatchingBeforeAddingInput;

// Additional (computed, statistical) data concerning the inputs
@property (readonly) float averageForce;
@property (readonly) float averageSpeed;
// ...

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (BOOL) isEmpty;
- (BOOL) hasFreeInputSlot;
- (UPFPatternInput*) getLastAddedInput;
- (BOOL) pathIsAcceptable : (UPFPatternPath*) path;
- (BOOL) addInput : (UPFPatternInput*) input;
- (BOOL) removeLastInput;
- (void) clear;

- (void) computeStatisticalData;

- (void) exportDataInFolderAtPath : (NSString*) path;

+ (UPFPatternInputSet*) createEmptyInputSetOfSize : (int) maxNbInputs
                                checkPathMatching : (BOOL) checkForPathMatching;
+ (UPFPatternInputSet*) createEmptyInputSetOfSize : (int) maxNbInputs;

- (id) copyWithZone : (NSZone *) zone;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
