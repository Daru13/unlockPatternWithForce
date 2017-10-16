//
//  UPFUnlockPatternPath.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFPatternNode.h"
#import "UPFPatternPathNode.h"

@interface UPFPatternPath : NSObject <NSCopying, NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

@property (readonly) NSMutableArray<UPFPatternPathNode*>* nodes;
@property (readonly) unsigned int nbNodes;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

+ (BOOL) pathsAreEquivalent : (UPFPatternPath*) path1
                            : (UPFPatternPath*) path2;

- (BOOL) isEmpty;
- (BOOL) isNodeInPath : (UPFPatternNode*) node;
- (UPFPatternPathNode*) getPathNodeAtIndex : (unsigned int) index;
- (void) continueWithNode : (UPFPatternNode*) node
                withForce : (unsigned int) force
                atTime    : (double) timestamp;
- (UPFPatternPathNode*) getFirstPathNode;
- (UPFPatternPathNode*) getLastPathNode;
- (void) clear;

- (void) exportDataInFileAtPath : (NSString*) path;

+ (UPFPatternPath*) createEmptyPath;
+ (UPFPatternPath*) createPathFromListOfNodes : (NSArray<UPFPatternNode*>*) nodes;

- (id) copyWithZone : (NSZone *) zone;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
