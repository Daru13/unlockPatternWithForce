//
//  UPFTouchEvent.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 15/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Log-able touch event information are defined in the structure below
typedef struct {
    CGPoint position;
    float   force;
    double  timestamp;
} UPFTouchEventInfo;

@interface UPFTouchEventLog : NSObject <NSCopying, NSCoding>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

@property NSString* _Nonnull pathToLogFile;

@property (readonly) unsigned int nbLoggedEvents;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (BOOL) isEmpty;
- (void) addTouchEvent : (UPFTouchEventInfo) eventInfo;
- (UPFTouchEventInfo) getTouchEventAt : (unsigned int) index;
- (UPFTouchEventInfo* _Nonnull) getAllTouchEvents;
- (void) clear;

- (void) exportDataInFileAtPath : (NSString*_Nonnull) path;

+ (UPFTouchEventLog*_Nonnull) createEmptyLog : (NSString*_Nonnull) saveFilePath;

- (id _Nonnull ) copyWithZone : (NSZone *_Nullable) zone;

- (void) encodeWithCoder : (NSCoder*_Nonnull) aCoder;
- (instancetype _Nonnull ) initWithCoder : (NSCoder*_Nonnull) aDecoder;

@end
