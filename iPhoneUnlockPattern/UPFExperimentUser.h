//
//  UPFExperimentUser.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 23/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UPFExperimentSession;

// Type of the unique user identifier
typedef unsigned long UPFUserId;

// Enumerated types for some user characteristics
typedef enum {
    MAIN_HAND_RIGHT,
    MAIN_HAND_LEFT,
    MAIN_HAND_AMBIDEXTROUS
} UPFUserMainHand;


@interface UPFExperimentUser : NSObject <NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Unique identifier
@property (readonly) UPFUserId userId;

// List of its sessions
@property (readonly) NSMutableArray<UPFExperimentSession*>* sessions;

// Information about the user
@property UPFUserMainHand mainHand;


// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

+ (NSString*) handednessToString : (UPFUserMainHand) mainHand;

- (BOOL) sessionNumberIsAvailable : (unsigned int) number;
- (void) addSession : (UPFExperimentSession*) session;
- (void) removeSessionAtIndex : (unsigned int) index;

- (void) exportDataInFolderAtPath : (NSString*) path;

+ (UPFExperimentUser*) createUserWithId : (UPFUserId) userId
                               mainHand : (UPFUserMainHand) mainHand;

- (void) encodeWithCoder : (NSCoder*) aCoder;
- (instancetype) initWithCoder : (NSCoder*) aDecoder;

@end
