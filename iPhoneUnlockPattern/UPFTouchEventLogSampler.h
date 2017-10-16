//
//  UPFTouchEventLogSampler.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 20/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPFTouchEventLog.h"

// Convenient log-tuple structure
// Note: field names are purly indicative for algorithms, which may choose to ignore the fact one log is the reference!
// However, each sampled logs must be put in the correct (= associated) field when the structure is used as a return value
typedef struct {
    UPFTouchEventLog* referenceLog;
    UPFTouchEventLog* otherLog;
} UPFLogSamplingTuple;

@protocol UPFTouchEventLogSampler <NSObject>

@required

// This method must align two touch event logs, so that the sampled versions both hold the same number of events
// In addition, the following restriction should be respected:
// If the first log holds N events and the second one holds M <= N events, the sampled logs must hold N >= K => M events
+ (UPFLogSamplingTuple) alignTouchEventLogs : (UPFLogSamplingTuple) logsToSample;

@end
