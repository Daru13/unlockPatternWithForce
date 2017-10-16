//
//  UPFExperiment.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 23/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UPFExperimentUser.h"
#import "UPFPatternPath.h"

@interface UPFExperiment : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Set of users who has taken part of the experiment
@property (readonly) NSMutableArray<UPFExperimentUser*>* users;

// --------------------------------------------------------------
// STATIC PROPERTIES
// --------------------------------------------------------------

// Class-level experiment singleton
+ (instancetype) sharedExperiment;

// Class-level useful URLs for file saving and (un)serialization
+ (NSURL*) pathToExperimentSerializedDataFile;
+ (NSURL*) pathToExperimentUsersFolder;

// Class-level list of reference pattern paths
+ (NSArray<UPFPatternPath*>*) listOfReferencePaths;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (BOOL) userIdIsAvailable : (UPFUserId) userId;
- (void) addUser : (UPFExperimentUser*) user;
- (void) removeUserAtIndex : (unsigned int) index;

+ (BOOL) fileExistsAtPath : (NSString*) path;
+ (BOOL) directoryExistsAtPath : (NSString*) path;
+ (void) createDirectoriesOfPath : (NSString*) path;
+ (void) createFileAndIntermediateDirectoriesAtPath : (NSString*) path
                                        withContent : (NSData*) content;
+ (NSData*) getFileDataAtPath : (NSString*) path;

- (void) serialize;
+ (instancetype) unserialize;

- (void) exportData;

+ (UPFExperiment*) createEmptyExperiment;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
