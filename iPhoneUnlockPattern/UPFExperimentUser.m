//
//  UPFExperimentUser.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 23/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFExperimentUser.h"
#import "UPFExperimentSession.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFExperimentUser ()

@property (readwrite) UPFUserId userId;

@property (readwrite) NSMutableArray<UPFExperimentSession*>* sessions;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFExperimentUser

// --------------------------------------------------------------
// HANDEDNESS TO STRING
// --------------------------------------------------------------

+ (NSString*) handednessToString : (UPFUserMainHand) mainHand {
    switch (mainHand) {
        case MAIN_HAND_LEFT:
            return @"Left-handed";
        case MAIN_HAND_RIGHT:
            return @"Right-handed";
        case MAIN_HAND_AMBIDEXTROUS:
            return @"Ambidextrous";
        default:
            return @"Unknown handedness";
    }
}

// --------------------------------------------------------------
// SESSION LIST EDITING
// --------------------------------------------------------------

- (BOOL) sessionNumberIsAvailable : (unsigned int) number {
    for (UPFExperimentSession* session in self.sessions)
        if (session.number == number)
            return false;
        
    return true;
}

- (void) addSession : (UPFExperimentSession*) session {
    [self.sessions addObject : session];
}

- (void) removeSessionAtIndex : (unsigned int) index {
    [self.sessions removeObjectAtIndex : index];
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

- (NSString*) getSessionFolderNameForIndex : (unsigned int) index {
    return [NSString stringWithFormat : @"session-%d", index + 1];
}

- (void) exportDataInFolderAtPath : (NSString*) path {
    // Export all sessions data, one folder per session
    for (unsigned int i = 0; i < self.sessions.count; i++) {
        UPFExperimentSession* currentSession = self.sessions[i];
        NSString* pathToCurrentSessionFolder = [path stringByAppendingPathComponent : [self getSessionFolderNameForIndex : i]];
        
        [currentSession exportDataInFolderAtPath : pathToCurrentSessionFolder];
    }
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method, for a given user ID
// It should be different from all previously created users — but this is not tested here!
+ (UPFExperimentUser*) createUserWithId : (UPFUserId) userId
                               mainHand : (UPFUserMainHand) mainHand {
    UPFExperimentUser* newUser = [UPFExperimentUser new];
    
    if (newUser) {
        newUser.userId   = userId;
        newUser.sessions = [NSMutableArray<UPFExperimentSession*> array];
        newUser.mainHand = mainHand;
    }
    
    return newUser;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : [NSNumber numberWithDouble : self.userId] forKey : @"userId"];
    [aCoder encodeObject : self.sessions                             forKey : @"sessions"];
    [aCoder encodeInt    : self.mainHand                             forKey : @"mainHand"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _userId   = [[aDecoder decodeObjectForKey : @"userId"] longValue];
        _sessions = [aDecoder decodeObjectForKey  : @"sessions"];
        _mainHand = [aDecoder decodeIntForKey     : @"mainHand"];
    }
    
    return self;
}

@end
