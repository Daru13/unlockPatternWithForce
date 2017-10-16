//
//  UPFUnlockPatternPath.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 13/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFPatternNode.h"
#import "UPFPatternPath.h"
#import "UPFPatternPathNode.h"
#import "UPFExperiment.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFPatternPath ()

@property (readwrite) NSMutableArray<UPFPatternPathNode*>* nodes;
@property (readwrite) unsigned int nbNodes;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFPatternPath

// --------------------------------------------------------------
// PATHS SIMILARTY TESTING
// --------------------------------------------------------------

// TODO: improve this :)
+ (BOOL) forcesAreEquivalent : (unsigned int) force1
                             : (unsigned int) force2 {
    int forceDifference = force1 - force2;
    return ABS(forceDifference) < 300; // completely arbitrary
}

// 'Equivalent' is defined as sufficiently close to be considered equal
// In other words, if an attemp path is equivalent to a solution path, then the attempt is a success
+ (BOOL) pathsAreEquivalent : (UPFPatternPath*) path1
                            : (UPFPatternPath*) path2 {
    NSUInteger path1Length = path1.nbNodes;
    NSUInteger path2Length = path2.nbNodes;
    
    // 1. Paths must go through the same number of nodes
    if (path1Length != path2Length)
        return NO;
    
    // 2. Compare the paths, node by node
    for (unsigned int index = 0; index < path1Length; index++) {
        UPFPatternPathNode* currentPathNode1 = path1.nodes[index];
        UPFPatternPathNode* currentPathNode2 = path2.nodes[index];
        
        UPFPatternNode* currentPatternNode1 = currentPathNode1.relatedPatternNode;
        UPFPatternNode* currentPatternNode2 = currentPathNode2.relatedPatternNode;
        
        // 2.1. Positions must be equal
        if (currentPatternNode1.row    != currentPatternNode2.row
        ||  currentPatternNode1.column != currentPatternNode2.column)
            return NO;
/*
        // 2.2. Forces must be equivalent (close enough)
        if (! [UPFPatternPath forcesAreEquivalent : currentPathNode1.selectionForce
                                                  : currentPathNode2.selectionForce])
            return NO;
*/
    }

    return YES;
}

// --------------------------------------------------------------
// OPERATIONS ON PATH NODES
// --------------------------------------------------------------

- (BOOL) isEmpty {
    return self.nbNodes == 0;
}

- (BOOL) isNodeInPath : (UPFPatternNode*) node {
    // Try to find a node in the path array which is at the same position
    NSUInteger pathNodeIndex = [self.nodes indexOfObjectPassingTest :
            ^ BOOL (id _Nonnull object, NSUInteger index, BOOL* _Nonnull stop) {
                UPFPatternPathNode* pathNode    = (UPFPatternPathNode*) object;
                UPFPatternNode*     patternNode = pathNode.relatedPatternNode;
                
                if (patternNode.row    == node.row
                &&  patternNode.column == node.column) {
                    *stop = YES;
                    return YES;
                }
                
                return NO;
            }];
    
    return pathNodeIndex != NSNotFound;
}

// Add a node at the end of the current path, with required metadata
// THIS METHOD DOES NOT CHECK WHETHER THE NODE ALREADY IS IN THE PATH OR NOT!
- (void) continueWithNode : (UPFPatternNode*) node
                withForce : (unsigned int) force
                atTime    : (double) timestamp {
    UPFPatternPathNode* pathNode = [UPFPatternPathNode createFromNode : node
                                                              atIndex : self.nbNodes
                                                            withForce : force
                                                               atTime : timestamp];
    
    [self.nodes addObject : pathNode];
    self.nbNodes++;
}

// If index is out of bound, return nil
- (UPFPatternPathNode*) getPathNodeAtIndex : (unsigned int) index {
    @try {
        return [self.nodes objectAtIndex : index];
    }
    @catch (NSException* exception) {
        return nil;
    }
}

// If there is no node, return nil
- (UPFPatternPathNode*) getFirstPathNode {
    return [self getPathNodeAtIndex : 0];
}

// If there is no node, return nil
- (UPFPatternPathNode*) getLastPathNode {
    return [self getPathNodeAtIndex : self.nbNodes - 1];
}

// Empty the list of nodes of the path
- (void) clear {
    [self.nodes removeAllObjects];
    self.nbNodes = 0;
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

/* EXPORT FORMAT FOR PATTERN PATH
 *
 * Exported data respects the following grammar:
 *
 * <nb of path nodes>
 * (<timestamp> <row> <column> <force>)*
 */

- (NSData*) getDataToExport {
    NSMutableData* data = [NSMutableData data];
    
    // First line: number of path nodes
    NSString* nbNodesAsString = [NSString stringWithFormat : @"%d\n", self.nbNodes];
    [data appendData : [nbNodesAsString dataUsingEncoding : NSUTF8StringEncoding]];
    
    // Next lines: descriptions of each path node, one per line
    for (unsigned int i = 0; i < self.nbNodes; i++) {
        UPFPatternPathNode* currentNode = self.nodes[i];
        
        NSString* currentNodeAsString = [NSString stringWithFormat : @"%lf %d %d %d\n",
                                         currentNode.selectionTimestamp,
                                         currentNode.relatedPatternNode.row,
                                         currentNode.relatedPatternNode.column,
                                         currentNode.selectionForce];
        [data appendData : [currentNodeAsString dataUsingEncoding : NSUTF8StringEncoding]];
    }
    
    return data;
}

- (void) exportDataInFileAtPath : (NSString*) path {
    NSData* dataToExport = [self getDataToExport];
    [UPFExperiment createFileAndIntermediateDirectoriesAtPath : path
                                                  withContent : dataToExport];
}


// --------------------------------------------------------------
// BUILDERS
// --------------------------------------------------------------

// Empty path builder method
+ (UPFPatternPath*) createEmptyPath {
    UPFPatternPath* newPath = [UPFPatternPath new];
    
    if (newPath) {
        newPath.nodes = [NSMutableArray new];
        newPath.nbNodes   = 0;
    }
    
    return newPath;
}

// Path builder method from a given list of (pattern) nodes
+ (UPFPatternPath*) createPathFromListOfNodes : (NSArray<UPFPatternNode*>*) nodes {
    UPFPatternPath* path = [UPFPatternPath createEmptyPath];
    
    for (unsigned int i = 0; i < nodes.count; i++) {
        [path continueWithNode : nodes[i]
                     withForce : 0
                        atTime : 0];
    }
    
    return path;
}

// --------------------------------------------------------------
// COPYING
// --------------------------------------------------------------

- (id) copyWithZone : (NSZone *) zone {
    UPFPatternPath* pathCopy = [UPFPatternPath new];
    
    if (pathCopy) {
        pathCopy.nodes = [self.nodes copy];
        pathCopy.nbNodes   = self.nbNodes;
    }
    
    return pathCopy;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.nodes   forKey : @"pathNodes"];
    [aCoder encodeInt    : self.nbNodes forKey : @"nbNodes"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];

    if (self) {
        _nodes   = [aDecoder decodeObjectForKey : @"pathNodes"];
        _nbNodes = [aDecoder decodeIntForKey    : @"nbNodes"];
    }
    
    return self;
}

@end
