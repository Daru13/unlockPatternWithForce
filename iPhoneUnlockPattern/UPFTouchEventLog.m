//
//  UPFTouchEvent.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 15/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFTouchEventLog.h"
#import "UPFExperiment.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFTouchEventLog ()

// Internal logged event mutable array
@property NSMutableArray* loggedEvents;

@property (readwrite) unsigned int nbLoggedEvents;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFTouchEventLog

// --------------------------------------------------------------
// LOG EDIT
// --------------------------------------------------------------

- (BOOL) isEmpty {
    return self.nbLoggedEvents == 0;
}

- (void) addTouchEvent : (UPFTouchEventInfo) eventInfo {
    // Since raw structures cannot be saved in an array, they are converted into a dictionnary
    NSDictionary* eventInfoAsDict = @{
        @"positionX" : [NSNumber numberWithUnsignedInt : eventInfo.position.x],
        @"positionY" : [NSNumber numberWithUnsignedInt : eventInfo.position.y],
        @"force"     : [NSNumber numberWithFloat       : eventInfo.force],
        @"timestamp" : [NSNumber numberWithDouble      : eventInfo.timestamp]
    };
    
    [self.loggedEvents addObject : eventInfoAsDict];
    self.nbLoggedEvents++;
}

- (UPFTouchEventInfo) getTouchEventAt : (unsigned int) index {
    // Get the logged value...
    NSDictionary* eventInfoAsDict = self.loggedEvents[index];
    
    // ...and fill the right data structure to return with it
    UPFTouchEventInfo eventInfo;
    eventInfo.position.x = [[eventInfoAsDict objectForKey : @"positionX"] unsignedIntValue];
    eventInfo.position.y = [[eventInfoAsDict objectForKey : @"positionY"] unsignedIntValue];
    eventInfo.force      = [[eventInfoAsDict objectForKey : @"force"    ] floatValue];
    eventInfo.timestamp  = [[eventInfoAsDict objectForKey : @"timestamp"] doubleValue];
    
    return eventInfo;
}

// Note: this method returns a raw C array, containing TouchEventInfo structures
// It thus must be free()'d when becoming useless, in order to avoid memory leaks
- (UPFTouchEventInfo*) getAllTouchEvents {
    UPFTouchEventInfo* touchEvents = malloc(self.nbLoggedEvents * sizeof(UPFTouchEventInfo));
    assert(touchEvents != NULL);
    
    for (unsigned int i = 0; i < self.nbLoggedEvents; i++)
        touchEvents[i] = [self getTouchEventAt : i];
    
    return touchEvents;
}

- (void) clear {
    [self.loggedEvents removeAllObjects];
    self.nbLoggedEvents = 0;
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

/* EXPORT FORMAT FOR TOUCH EVENT LOG
 *
 * Exported data respects the following grammar:
 *
 * <nb of logged events>
 * (<timestamp> <x> <y> <force>)*
 */

- (NSData*) getDataToExport {
    NSMutableData* data = [NSMutableData data];
    
    // First line: number of logged touch events
    NSString* nbloggedEventsAsString = [NSString stringWithFormat : @"%d\n", self.nbLoggedEvents];
    [data appendData : [nbloggedEventsAsString dataUsingEncoding : NSUTF8StringEncoding]];
    
    // Next lines: descriptions of each logged touch events, one per line
    for (unsigned int i = 0; i < self.nbLoggedEvents; i++) {
        UPFTouchEventInfo currentTouchEvent = [self getTouchEventAt : i];
        
        NSString* currentTouchEventAsString = [NSString stringWithFormat : @"%lf %lf %lf %f\n",
                                               currentTouchEvent.timestamp,
                                               currentTouchEvent.position.x,
                                               currentTouchEvent.position.y,
                                               currentTouchEvent.force];
        [data appendData : [currentTouchEventAsString dataUsingEncoding : NSUTF8StringEncoding]];
    }
    
    return data;
}


- (void) exportDataInFileAtPath : (NSString*) path {
    NSData* dataToExport = [self getDataToExport];
    [UPFExperiment createFileAndIntermediateDirectoriesAtPath : path
                                                  withContent : dataToExport];
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

+ (UPFTouchEventLog*) createEmptyLog : (NSString*) saveFilePath {
    UPFTouchEventLog* newLogger = [UPFTouchEventLog new];
    
    if (newLogger) {
        newLogger.loggedEvents   = [NSMutableArray new];
        newLogger.nbLoggedEvents = 0;
        
        newLogger.pathToLogFile = saveFilePath;
    }
    
    return newLogger;
}

// --------------------------------------------------------------
// COPYING
// --------------------------------------------------------------

- (id) copyWithZone : (NSZone *) zone {
    UPFTouchEventLog* logCopy = [UPFTouchEventLog new];
    
    if (logCopy) {
        logCopy.loggedEvents   = [self.loggedEvents copy];
        logCopy.nbLoggedEvents = self.nbLoggedEvents;
    }
    
    return logCopy;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.pathToLogFile  forKey : @"pathToLogFile"];
    [aCoder encodeObject : self.loggedEvents   forKey : @"loggedEvents"];
    [aCoder encodeInt    : self.nbLoggedEvents forKey : @"nbLoggedEvents"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _pathToLogFile  = [aDecoder decodeObjectForKey : @"pathToLogFile"];
        _loggedEvents   = [aDecoder decodeObjectForKey : @"loggedEvents"];
        _nbLoggedEvents = [aDecoder decodeIntForKey    : @"nbLoggedEvents"];
    }
    
    return self;
}

@end
