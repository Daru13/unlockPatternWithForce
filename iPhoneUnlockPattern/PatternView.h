//
//  UnlockPatternView.h
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 14/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
// #import "compatibilityFix.h"

#import "UPFPattern.h"
#import "UPFPatternPath.h"
#import "UPFTouchEventLog.h"
#import "UPFPatternInput.h"

@interface PatternView : UIView

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

// Whole pattern used a reference (for drawing, etc)
@property UPFPattern* pattern;

// Timer (regular callbacks) frequencies
@property (readonly) NSTimeInterval graphicalUpdateTimeInterval;
@property (readonly) NSTimeInterval multitouchEventProcessingTimeInterval;

// Timer (single callback) durations
@property (readonly) NSTimeInterval inputErrorDisplayDuration;

// View dimensions
@property (readonly) unsigned int width;
@property (readonly) unsigned int height;

// Margin of the grid-drawing area
@property unsigned int gridLeftMargin;
@property unsigned int gridRightMargin;
@property unsigned int gridTopMargin;
@property unsigned int gridBottomMargin;

// Margin of the node-drawing area
@property unsigned int nodeLeftMargin;
@property unsigned int nodeRightMargin;
@property unsigned int nodeTopMargin;
@property unsigned int nodeBottomMargin;

// Colors used from drawing
@property UIColor* patternNodeColor;
@property UIColor* userInputPathNodeColor;
@property UIColor* userInputPathSegmentColor;
@property UIColor* patternReferencePathNodeColor;
@property UIColor* patternReferenceSegmentColor;
@property UIColor* erroneousPathNodeColor;
@property UIColor* erroneousPathSegmentColor;

// Thicknesses used for drawing
@property float pathSegmentLineThickness;
@property float touchEventLineThickness;

// Other drawing parameters
@property BOOL enableUserInputPathDrawing;
@property BOOL enableUserInputTouchEventLogDrawing;
@property BOOL enablePatternReferenceInputPathDrawing;
@property BOOL enablePatternReferenceInputTouchEventLogDrawing;
@property BOOL enablePathSegmentToTouchedPointDrawing;
@property BOOL enableTextualPathNodeDetailsDrawing;

@property BOOL scalePathNodesAccordingToSelectionForce;
@property BOOL makeFirstPathNodeBigger;
@property BOOL drawArrowsOnReferencePathSegments;

// Other parameters
@property BOOL enableUserInput;

// Current user input (path + touch event log)
@property (readonly) UPFPatternInput* userInput;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) initPropertiesWithDefaultValues;

- (void) startRegularGraphicalUpdate;
- (void) startRegularMultitouchEventProcessing;
- (void) stopRegularGraphicalUpdate;
- (void) stopRegularMultitouchEventProcessing;

- (void) onTouchBegan;
- (void) onTouchMoved;
- (void) onTouchEnded;

- (void) discardErroneousUserInput;
- (void) handleErroneousUserInput;

@end
