//
//  UnlockPatternView.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 14/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "PatternView.h"
#import "UPFPatternGrid.h"
#import "UPFPatternPath.h"
#import "UPFPatternPathNode.h"
#import "UPFPatternNode.h"
#import "UPFTouchEventLog.h"

#import "UPFDynamicTimeWarping.h"
#import "UPFDerivativeDynamicTimeWarping.h"

// ----------------------------------------------------------------- Internal interface ---

@interface PatternView ()

@property (readwrite) unsigned int width;
@property (readwrite) unsigned int height;

@property (readwrite) UPFPatternInput* userInput;

// Set of all touch events
@property NSSet<UITouch*>* allTouchEvents;

// Internal references to timers
@property NSTimer* touchEventProcessingTimer;
@property NSTimer* graphicalUpateTimer;
@property NSTimer* inputErrorDisplayTimer;

// Internal user-input ignoring mode
@property BOOL ignoreUserInput;

// Internal erroneous-user input flag
@property BOOL userInputIsErroneous;

@end

// -------------------------------------------------------------- Actual implementation ---


@implementation PatternView

// --------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------

// Set default values to various parameters
- (void) initPropertiesWithDefaultValues {
    // Grid margins
    _gridTopMargin    = 10;
    _gridLeftMargin   = 10;
    _gridRightMargin  = 10;
    _gridBottomMargin = 10;
    
    // Node margins
    _nodeTopMargin    = 25;
    _nodeLeftMargin   = 25;
    _nodeRightMargin  = 25;
    _nodeBottomMargin = 25;
    
    // Dimensions
    _width  = super.bounds.size.width;
    _height = super.bounds.size.width;
    
    // Drawing colors
    _patternNodeColor              = [UIColor lightGrayColor];
    _userInputPathNodeColor        = [UIColor colorWithRed : 0.10f
                                                     green : 0.65f
                                                      blue : 0.10f
                                                     alpha : 1.00f];
    _userInputPathSegmentColor     = [UIColor colorWithRed : 0.05f
                                                     green : 0.35f
                                                      blue : 0.05f
                                                     alpha : 1.00f];
    _patternReferencePathNodeColor = [UIColor darkGrayColor];
    _patternReferenceSegmentColor  = [UIColor darkGrayColor];
    _erroneousPathNodeColor        = [UIColor colorWithRed : 0.65f
                                                     green : 0.10f
                                                      blue : 0.10f
                                                     alpha : 1.00f];
    _erroneousPathSegmentColor     = [UIColor colorWithRed : 0.35f
                                                     green : 0.05f
                                                      blue : 0.05f
                                                     alpha : 1.00f];
    
    // Drawing thicknesses
    _pathSegmentLineThickness = 10.0f;
    _touchEventLineThickness  = 3.5f;
    
    // Other drawing parameters
    _enableUserInputPathDrawing                      = YES;
    _enableUserInputTouchEventLogDrawing             = YES;
    _enablePatternReferenceInputPathDrawing          = YES;
    _enablePatternReferenceInputTouchEventLogDrawing = YES;
    _enablePathSegmentToTouchedPointDrawing          = YES;
    _enableTextualPathNodeDetailsDrawing             = NO;
    
    _scalePathNodesAccordingToSelectionForce = NO;
    _makeFirstPathNodeBigger                 = NO;
    _drawArrowsOnReferencePathSegments       = YES;
    
    // Other parameters
    _enableUserInput = YES;
    
    // Timer intervals
    _graphicalUpdateTimeInterval           = 0.02f;  // 50Hz
    _multitouchEventProcessingTimeInterval = 0.01f;  // 100Hz
    
    // Timer durations
    _inputErrorDisplayDuration = 0.32f;
    
    // Create an empty user input
    _userInput = [UPFPatternInput createEmptyInput];
    
    // Create an empty event set
    _allTouchEvents = [NSSet<UITouch*> set];
    
    // By default, do not internally ignore user inputs
    _ignoreUserInput = NO;
    
    // By default, the user input is not erroneous
    _userInputIsErroneous = NO;
}

// General initializaton function
// It calls other init functions in the right order + perform additional init tasks
- (id) init {
    self = [super init];
    
    // Initialize properties
    [self initPropertiesWithDefaultValues];
    
    return self;
}

// Automatically called when the view is constructed by the App
- (void) awakeFromNib {
    [super awakeFromNib];
    
    id __unused _ = [self init];
}

// --------------------------------------------------------------
// MULTITOUCH (+ PRESSURE) EVENT HANDLING INIT
// --------------------------------------------------------------

- (void) touchesBegan : (NSSet<UITouch*>*) touches
            withEvent : (UIEvent *) event
{
    if ((! self.enableUserInput) || self.ignoreUserInput)
        return;
    
    self.allTouchEvents = [event allTouches];
    [self onTouchBegan];
}

- (void) touchesMoved : (NSSet<UITouch*>*) touches
            withEvent : (UIEvent *) event
{
    if ((! self.enableUserInput) || self.ignoreUserInput)
        return;
    
    self.allTouchEvents = [event allTouches];
    [self onTouchMoved];
}

- (void) touchesEnded : (NSSet<UITouch*>*) touches
            withEvent : (UIEvent *) event
{
    if ((! self.enableUserInput) || self.ignoreUserInput)
        return;
    
    self.allTouchEvents = [event allTouches];
    [self onTouchEnded];
}

// --------------------------------------------------------------
// REGULAR MULTITOUCH EVENTS PROCESSING
// --------------------------------------------------------------

- (void) onTouchBegan {
    // Should be overriden by sublcasses, if required
}

- (void) onTouchMoved {
    // Should be overidden by subclasses, if required
}

- (void) onTouchEnded {
    // If a reference path is defined, compare it to the current path
    if ([self.pattern referenceInputSetIsDefined]) {
        if ([self.pattern matchesWithInput : self.userInput]) {
            NSLog(@"Input is correct");
/*
            NSLog(@"********************************************");
            [UPFDynamicTimeWarping           getMatchingScoreOfInput:self.userInput withPattern:self.pattern];
            NSLog(@"\n");
            [UPFDerivativeDynamicTimeWarping getMatchingScoreOfInput:self.userInput withPattern:self.pattern];
*/
            [self.userInput clear];
        }
        else {
            NSLog(@"Input is NOT correct, sorry!");
            [self handleErroneousUserInput];
        }
    }
    else {
        NSLog(@"No reference input for comparison...");
        [self handleErroneousUserInput];
    }
    
    
}

// Process the set of touch events
- (void) processTouchEvents {
    if ((! self.enableUserInput) || self.ignoreUserInput)
        return;
    
    CGRect gridBoundingRect = [self getPatternGridBoudingRect : self.pattern.nodeGrid];
    
    // Handle all the touch events
    for (UITouch* touchEvent in self.allTouchEvents) {
        
        // Get some info on the "touched" point
        CGPoint        position  = [touchEvent locationInView : self];
        float          force     = touchEvent.force;
        NSTimeInterval timestamp = touchEvent.timestamp;
        
        // DEBUG
        // NSLog(@"Touch event (at [%f, %f], with force %f)", position.x, position.y, force);
        
        // 2. Check if the current contact point is hovering a pattern node
        UPFPatternNode* hoveredNode = [self getNodeBelowPoint : position
                                                              : gridBoundingRect];
        
        // If a node is found and not in the current path yet, it is added at the end of the path
        if (hoveredNode && (! [self.userInput.patternPath isNodeInPath : hoveredNode]))
            [self.userInput.patternPath continueWithNode : hoveredNode
                                               withForce : (unsigned int) force
                                                  atTime : timestamp];
        
        // 3. Finally, multitouch event information must be logged
        UPFTouchEventInfo eventInfo;
        eventInfo.position  = position;
        eventInfo.force     = force;
        eventInfo.timestamp = timestamp;
        
        [self.userInput.touchEventLog addTouchEvent : eventInfo];
    }
}

// Install a timer for regular multitouch event processing
- (void) startRegularMultitouchEventProcessing {
    self.touchEventProcessingTimer = [NSTimer scheduledTimerWithTimeInterval : self.multitouchEventProcessingTimeInterval
                                                                      target : self
                                                                    selector : @selector(processTouchEvents)
                                                                    userInfo : nil
                                                                     repeats : YES];
}

- (void) stopRegularMultitouchEventProcessing {
    [self.touchEventProcessingTimer invalidate];
    self.touchEventProcessingTimer = nil;
}

// --------------------------------------------------------------
// REGULAR GRAPHICAL UPDATE
// --------------------------------------------------------------

// Install a timer for regular view updates
- (void) startRegularGraphicalUpdate {
    self.graphicalUpateTimer = [NSTimer scheduledTimerWithTimeInterval : self.graphicalUpdateTimeInterval
                                                                target : self
                                                              selector : @selector(setNeedsDisplay)
                                                              userInfo : nil
                                                               repeats : YES];
}

- (void) stopRegularGraphicalUpdate {
    [self.graphicalUpateTimer invalidate];
    self.graphicalUpateTimer = nil;
}

// --------------------------------------------------------------
// USER INPUT ERROR HANDLING
// --------------------------------------------------------------

- (void) discardErroneousUserInput {
    // Stop the error display timer
    [self stopDisplayingErrorInput];
    
    // Reset variables holding error info/state
    [self.userInput clear];
    self.userInputIsErroneous = NO;
    
    // Stop ignoring touch events
    self.ignoreUserInput = NO;
}

- (void) stopDisplayingErrorInput {
    // Cancel and reset the timer and the property holding its reference
    if (self.inputErrorDisplayTimer)
        [self.inputErrorDisplayTimer invalidate];
    self.inputErrorDisplayTimer = nil;
}

- (void) startDisplayingErrorInput {
    // Start a single-time timer, in order to discard error display after a short amount of time
    self.inputErrorDisplayTimer = [NSTimer scheduledTimerWithTimeInterval : self.inputErrorDisplayDuration
                                                                   target : self
                                                                 selector : @selector(discardErroneousUserInput)
                                                                 userInfo : nil
                                                                  repeats : NO];
}

- (void) handleErroneousUserInput {
    // Start ignoring touch events
    self.ignoreUserInput = YES;
    
    // Set variable holding error state
    self.userInputIsErroneous = YES;
    
    // Start the error display timer
    [self startDisplayingErrorInput];
}

// --------------------------------------------------------------
// VIEW DIMENSIONS UPDATE
// --------------------------------------------------------------

/*
// View dimensions should be updated BEFORE ANY DRAWING, whenever they may have changed
- (void) updateDimensions : (CGSize) dimensions {
    // Change the "canvas" dimensions
    self.width  = dimensions.width;
    self.height = dimensions.height;
    
    NSLog(@"CGRect width: %lf", dimensions.width);
    NSLog(@"CGRect height: %lf", dimensions.height);
    
    // Update the window and view's size
    CGRect frameRect;
    frameRect.origin.x = 0;
    frameRect.origin.y = 0;
    frameRect.size     = dimensions;
    
    [self.window setFrame : frameRect
                 display  : NO];
    [self        setFrame : frameRect];
    
    // Force a redraw
    [self forceViewUpdate];
}
*/

// --------------------------------------------------------------
// BOUNDING RECTANGLES COMPUTATION
// --------------------------------------------------------------

// Return a CGRect instance representing the bouding rectangle of an unlock pattern grid
// This method takes into account drawing parameters such as margins
- (CGRect) getPatternGridBoudingRect : (UPFPatternGrid*) grid {
    CGRect gridBoundingRect;
    
    gridBoundingRect.origin.x = self.gridLeftMargin;
    gridBoundingRect.origin.y = self.gridTopMargin;
    
    gridBoundingRect.size.width  = self.width  - (self.gridLeftMargin + self.gridRightMargin);
    gridBoundingRect.size.height = self.height - (self.gridTopMargin  + self.gridBottomMargin);
    
    return gridBoundingRect;
}

// Return a CGRect instance representing the bouding rectangle of an unlock pattern node
// This method takes into account drawing parameters such as margins
- (CGRect) getPatternNodeBoundingRect : (UPFPatternNode*) node
                                      : (CGRect) gridBoundingRect {
    CGRect nodeBoundingRect;
    
    // Grid cell dimensions (without any margin)
    unsigned int cellWidth  = (gridBoundingRect.size.width / self.pattern.nodeGrid.nbColumns);
    unsigned int cellHeight = (gridBoundingRect.size.height / self.pattern.nodeGrid.nbRows);
    
    nodeBoundingRect.origin.x = gridBoundingRect.origin.x
                              + (cellWidth * node.column)
                              + (self.nodeLeftMargin);
    nodeBoundingRect.origin.y = gridBoundingRect.origin.y
                              + (cellHeight * node.row)
                              + (self.nodeTopMargin);
    
    nodeBoundingRect.size.width  = cellWidth  - (self.nodeLeftMargin + self.nodeRightMargin);
    nodeBoundingRect.size.height = cellHeight - (self.nodeTopMargin  + self.nodeBottomMargin);

    /*
    // Debug for logging node slection zones coords, for matching algorithm purposes
    NSLog(@"Node at %d, %d: x: %f y: %f w: %f: h: %f",
          node.row, node.column,
          nodeBoundingRect.origin.x, nodeBoundingRect.origin.y,
          nodeBoundingRect.size.width, nodeBoundingRect.size.height);
    */
    
    return nodeBoundingRect;
}

// Return a CGRect instance representing the bounding rectangle of a path node
// Note: it may differ from the pattern node's bounding rectangle (e.g. selection force is used as a modifier)
- (CGRect) getPathNodeBoundingRect : (UPFPatternPathNode*) pathNode
                                   : (CGRect) gridBoundingRect {
    // Get the related pattern node's bounding rect
    CGRect pathNodeBoundingRect = [self getPatternNodeBoundingRect : pathNode.relatedPatternNode
                                                                   : gridBoundingRect];
    
    // If the option is set, scale it accordingly to the force
    if (self.scalePathNodesAccordingToSelectionForce) {
        float ratio = (((float) pathNode.selectionForce) / 14) + 0.9f;
        
        float oldWidth  = pathNodeBoundingRect.size.width;
        float oldHeight = pathNodeBoundingRect.size.height;
        float newWidth  = pathNodeBoundingRect.size.width  * ratio;
        float newHeight = pathNodeBoundingRect.size.height * ratio;
        
        pathNodeBoundingRect.size.width  = newWidth;
        pathNodeBoundingRect.size.height = newHeight;
        pathNodeBoundingRect.origin.x += (oldWidth - newWidth)  / 2;
        pathNodeBoundingRect.origin.y += (oldHeight - newHeight) / 2;
    }

    
    return pathNodeBoundingRect;
}

// --------------------------------------------------------------
// POSITION DETECTION/NODE RETRIEVAL
// --------------------------------------------------------------

// Return true if a given point is inside a given node
- (BOOL) isPointInPatternNode : (CGPoint) point
                              : (UPFPatternNode*) node
                              : (CGRect) gridBoundingRect {
    // TODO: improve this to better check the point position?
    CGRect nodeBoundingRect = [self getPatternNodeBoundingRect : node : gridBoundingRect];
    return [[UIBezierPath bezierPathWithOvalInRect : nodeBoundingRect] containsPoint : point];
}

// Return the grid node below the given point if any match; nil otherwise
- (UPFPatternNode*) getNodeBelowPoint : (CGPoint) point
                                            : (CGRect) gridBoundingRect {
    for (UPFPatternNode* node in self.pattern.nodeGrid)
        if ([self isPointInPatternNode : point : node : gridBoundingRect])
            return node;
    
    return nil;
}

// --------------------------------------------------------------
// PATTERN DRAWING
// --------------------------------------------------------------

- (CGPoint) getNodeCenter : (UPFPatternNode*) node
                          : (CGRect) gridBoundingRect {
    CGRect nodeBoundingRect = [self getPatternNodeBoundingRect : node
                                                               : gridBoundingRect];
    
    return CGPointMake(nodeBoundingRect.origin.x + (nodeBoundingRect.size.width  / 2),
                       nodeBoundingRect.origin.y + (nodeBoundingRect.size.height / 2));
}


- (void) drawPatternNode : (UPFPatternNode*) node
                         : (CGRect) gridBoundingRect {
    CGRect nodeBoundingRect = [self getPatternNodeBoundingRect : node : gridBoundingRect];
    
    // Set the pattern node's color
    UIColor* nodeColor    = self.patternNodeColor;
    
    // If touch input is disabled, make the pattern nodes brighter for a visual hint about that
    if (! self.enableUserInput) {
        CGFloat hue, saturation, brightness, alpha;
        
        [nodeColor getHue : &hue saturation : &saturation brightness : &brightness alpha : &alpha];
        nodeColor = [UIColor colorWithHue : hue
                               saturation : saturation
                               brightness : brightness + (1.0 - brightness)/2
                                    alpha : alpha];
    }
    [nodeColor set];

    // Draw a small, filled disc
    UIBezierPath* smallDisc = [UIBezierPath bezierPathWithArcCenter : [self getNodeCenter : node : gridBoundingRect]
                                                             radius : 1.5f * self.pathSegmentLineThickness
                                                         startAngle : 0
                                                           endAngle : 2 * M_PI
                                                           clockwise: YES];
    [smallDisc fill];
    
    // Draw a larger, stroked circle
    UIBezierPath* largeCircle = [UIBezierPath bezierPathWithOvalInRect : nodeBoundingRect];
    largeCircle.lineWidth = 2.0f;
    [largeCircle stroke];
}

- (void) drawAllPatternNodes {
    CGRect gridBoundingRect = [self getPatternGridBoudingRect : self.pattern.nodeGrid];
    
    // Draw all the nodes of the unlock pattern' grid
    for (UPFPatternNode* node in self.pattern.nodeGrid)
        [self drawPatternNode : node : gridBoundingRect];
}

// --------------------------------------------------------------
// TOUCH EVENT DRAWING
// --------------------------------------------------------------

- (void) drawTouchEvent : (UITouch*) touchEvent {
    // Get some info about the event
    CGPoint        position  = [touchEvent locationInView : self];
    float          force     = touchEvent.force;
    
    // Compute the touched point bounding box
    CGRect pointBoundingRect;
    pointBoundingRect.origin.x = (position.x * self.width)  - 18;
    pointBoundingRect.origin.y = (position.y * self.height) - 10;
    pointBoundingRect.size.width  = 34;
    pointBoundingRect.size.height = 20;
    
    // Draw the touched point stroke
    [[UIColor blueColor] set];
    UIBezierPath* graphicalPoint = [UIBezierPath bezierPathWithOvalInRect : pointBoundingRect];
    [graphicalPoint stroke];
    
    // Draw the pressure value as well
    NSString* textPressure = [NSString stringWithFormat : @"%.0f", force];
    [textPressure drawAtPoint    : CGPointMake(pointBoundingRect.origin.x + 10,
                                               pointBoundingRect.origin.y + 4)
                  withAttributes : nil];
}

- (void) drawAllTouchEvents {
    for (UITouch* touchEvent in self.allTouchEvents)
        [self drawTouchEvent : touchEvent];
}

// --------------------------------------------------------------
// LOGGED TOUCH EVENT DRAWING
// --------------------------------------------------------------

- (void) drawTouchEventInfo : (UPFTouchEventInfo) touchEventInfo {
    // Create a bouding rectangle around the touch event
    CGFloat boundingBoxSideLength = floorf(touchEventInfo.force * 3.5f) + 5.0f;
    CGFloat boundingBoxX = touchEventInfo.position.x - (boundingBoxSideLength / 2);
    CGFloat boundingBoxY = touchEventInfo.position.y - (boundingBoxSideLength / 2);
    
    CGRect touchEventBoundingRect = CGRectMake(boundingBoxX, boundingBoxY, boundingBoxSideLength, boundingBoxSideLength);
    
    // Compute and set the color the disk must be drawn with
    UIColor* touchEventColor = [UIColor colorWithRed : 0.0f + (touchEventInfo.force / 7)
                                               green : 1.0f - (touchEventInfo.force / 7)
                                                blue : 1.0f - (touchEventInfo.force / 7)
                                               alpha : 1.0f];
    [touchEventColor set];
    
    // Draw a disc representing the touch event
    UIBezierPath* touchEventDisc = [UIBezierPath bezierPathWithOvalInRect : touchEventBoundingRect];
    //touchEventDisc.lineWidth = self.touchEventLineThickness;
    [touchEventDisc fill];
}

- (void) drawTouchEventLog : (UPFTouchEventLog*) touchEventLog {
    UPFTouchEventInfo* allTouchEventInfo = [touchEventLog getAllTouchEvents];
    
    for (unsigned int i = 0; i < touchEventLog.nbLoggedEvents; i++)
        [self drawTouchEventInfo : allTouchEventInfo[i]];
    
    free(allTouchEventInfo);
}

// --------------------------------------------------------------
// PATH DRAWING
// --------------------------------------------------------------

- (CGPoint) getPathNodeCenter : (UPFPatternPathNode*) pathNode
                              : (CGRect) gridBoundingRect {
    CGRect nodeBoundingRect = [self getPathNodeBoundingRect : pathNode
                                                            : gridBoundingRect];
    
    return CGPointMake(nodeBoundingRect.origin.x + (nodeBoundingRect.size.width  / 2),
                       nodeBoundingRect.origin.y + (nodeBoundingRect.size.height / 2));
}

- (void) drawTextualDetailsOfPathNode : (UPFPatternPathNode*) pathNode
                                      : (CGRect) nodeBoundingRect {
    UPFPatternNode* node = pathNode.relatedPatternNode;
    
    // Create a string containing the details
    NSString* nodeInfo = [NSString stringWithFormat : @"Position: [row: %u, col: %u]\nIndexInPath: %d, Force: %d",
                          node.row, node.column,
                          pathNode.indexInPath, pathNode.selectionForce];
    
    // Draw the string in the left-center of the node's disc
    [[UIColor blackColor] set];
    
    [nodeInfo drawAtPoint : CGPointMake(nodeBoundingRect.origin.x + 20,
                                        nodeBoundingRect.origin.y + (nodeBoundingRect.size.height / 2) - 12)
           withAttributes : nil];
}

- (void) drawPathNode : (UPFPatternPathNode*) pathNode
                      : (BOOL) isFirstNode
                      : (CGRect) gridBoundingRect {
    CGRect pathNodeBoundingRect = [self getPathNodeBoundingRect : pathNode : gridBoundingRect];
    
    // Draw a filled disc in the middle
    // It the option is set, it is large if it is the first node of the path, and small otherwise
    float discRadius;
    if (isFirstNode && self.makeFirstPathNodeBigger)
        discRadius = (pathNodeBoundingRect.size.width - 14.0f) / 2.0f;
    else
        discRadius = 1.5f * self.pathSegmentLineThickness;
    
    UIBezierPath* centralDisc = [UIBezierPath bezierPathWithArcCenter : [self getPathNodeCenter : pathNode : gridBoundingRect]
                                                               radius : discRadius
                                                           startAngle : 0
                                                             endAngle : 2 * M_PI
                                                            clockwise : YES];
    [centralDisc fill];
    
    // ...and draw a large, stroked circle
    UIBezierPath* peripheralCircle = [UIBezierPath bezierPathWithOvalInRect : pathNodeBoundingRect];
    peripheralCircle.lineWidth = 2.0f;
    [peripheralCircle stroke];

    // If the option is set, also draw textual information about the node
    if (self.enableTextualPathNodeDetailsDrawing)
        [self drawTextualDetailsOfPathNode : pathNode
                                           : pathNodeBoundingRect];
}

- (void) drawPathSegmentArrowFromPoint : (CGPoint) originPoint
                               toPoint : (CGPoint) destinationPoint {
    // 1. Compute and normalize the segment vector
    CGPoint segmentVector = CGPointMake(destinationPoint.x - originPoint.x,
                                        destinationPoint.y - originPoint.y);
    float segmentVectorLength = sqrtf(  segmentVector.x * segmentVector.x
                                      + segmentVector.y * segmentVector.y);
    CGPoint normalizedSegmentVector = CGPointMake(segmentVector.x / segmentVectorLength,
                                                  segmentVector.y / segmentVectorLength);
    
    // 2. Compute the two normal (normalized) vectors
    CGPoint firstNormalVector  = CGPointMake(- normalizedSegmentVector.y,   normalizedSegmentVector.x);
    CGPoint secondNormalVector = CGPointMake(  normalizedSegmentVector.y, - normalizedSegmentVector.x);

    // 3. Compute all the points of the arrow, by translating vectors
    float originToEndTranslationRatio = 0.4f;
    
    CGPoint firstArrowEnd  = CGPointMake(  firstNormalVector.x * 20
                                         + originPoint.x
                                         + (originToEndTranslationRatio * segmentVector.x),
                                         firstNormalVector.y * 20
                                         + originPoint.y
                                         + (originToEndTranslationRatio * segmentVector.y));
    CGPoint secondArrowEnd = CGPointMake(  secondNormalVector.x * 20
                                         + originPoint.x
                                         + (originToEndTranslationRatio * segmentVector.x),
                                           secondNormalVector.y * 20
                                         + originPoint.y
                                         + (originToEndTranslationRatio * segmentVector.y));
    CGPoint arrowCenter    = CGPointMake(  originPoint.x
                                         + ((originToEndTranslationRatio) * segmentVector.x)
                                         + 20.0f * normalizedSegmentVector.x,
                                           originPoint.y
                                         + ((originToEndTranslationRatio) * segmentVector.y)
                                         + 20.0f * normalizedSegmentVector.y);
    
    // 4. Draw the arrow
    UIBezierPath* arrowSegment = [UIBezierPath bezierPath];
    [arrowSegment moveToPoint    : firstArrowEnd];
    [arrowSegment addLineToPoint : arrowCenter];
    [arrowSegment addLineToPoint : secondArrowEnd];
    
    arrowSegment.lineWidth = self.pathSegmentLineThickness / 2.0f;
    [arrowSegment stroke];
}

- (void) drawPathSegmentFromPoint : (CGPoint) originPoint
                          toPoint : (CGPoint) destinationPoint
                       withArrows : (BOOL) drawArrows
                                  : (CGRect) gridBoundingRect {
    // Build the line between the two points
    UIBezierPath* pathSegment = [UIBezierPath bezierPath];
    [pathSegment moveToPoint    : originPoint];
    [pathSegment addLineToPoint : destinationPoint];
    
    // Draw the line
    pathSegment.lineWidth = self.pathSegmentLineThickness;
    [pathSegment stroke];
    
    if (drawArrows)
        [self drawPathSegmentArrowFromPoint : originPoint
                                    toPoint : destinationPoint];
}

- (void) drawPathSegmentFrom : (UPFPatternPathNode*) origin
                          to : (UPFPatternPathNode*) destination
                  withArrows : (BOOL) drawArrows
                             : (CGRect) gridBoundingRect {
    // Get the nodes' centers
    CGPoint originCenter      = [self getPathNodeCenter : origin      : gridBoundingRect];
    CGPoint destinationCenter = [self getPathNodeCenter : destination : gridBoundingRect];
    
    // Draw the segment between them
    [self drawPathSegmentFromPoint : originCenter
                           toPoint : destinationCenter
                        withArrows : drawArrows
                                   : gridBoundingRect];
}

- (void) drawAllPathNodes : (UPFPatternPath*) path {
    // Iterate over every path node
    CGRect gridBoundingRect = [self getPatternGridBoudingRect : self.pattern.nodeGrid];
    
    for (unsigned int i = 0; i < path.nbNodes; i++) {
        UPFPatternPathNode* currentPathNode = [path getPathNodeAtIndex : i];
        BOOL                isFirstNode     = (i == 0);
        
        [self drawPathNode : currentPathNode : isFirstNode : gridBoundingRect];
    }
}

- (void) drawAllPathSegments : (UPFPatternPath*) path
                  withArrows : (BOOL) drawArrows {
    // If there are less than two nodes in the path, there is nothing to draw
    if (path.nbNodes < 1)
        return;
    
    // Othrewise, iterate over the path nodes to get both origins and destinations
    CGRect gridBoundingRect = [self getPatternGridBoudingRect : self.pattern.nodeGrid];
    
    for (int i = 1; i < path.nbNodes; i++) {
        UPFPatternPathNode* originPathNode      = [path getPathNodeAtIndex : i - 1];
        UPFPatternPathNode* destinationPathNode = [path getPathNodeAtIndex : i    ];
        
        [self drawPathSegmentFrom : originPathNode
                               to : destinationPathNode
                       withArrows : drawArrows
                                  : gridBoundingRect];
    }
}

- (void) drawSegmentFromLastPathNodeToLastTouchedPoint {
    // If there is no touched point, or if path has no node, there is nothing to draw
    if (self.allTouchEvents.count == 0 || [self.userInput.patternPath isEmpty])
        return;
    
    // If user input is disabled or ignored, there is nothing to draw either
    if ((! self.enableUserInput) || self.ignoreUserInput)
        return;
    
    CGRect gridBoundingRect = [self getPatternGridBoudingRect : self.pattern.nodeGrid];
    
    // Get the two points
    CGPoint originPoint      = [self getPathNodeCenter : [self.userInput.patternPath getLastPathNode] : gridBoundingRect];
    CGPoint destinationPoint = [[self.allTouchEvents anyObject] locationInView : self];
    
    // Draw the segment between them
    [self drawPathSegmentFromPoint : originPoint
                           toPoint : destinationPoint
                        withArrows : NO
                                   : gridBoundingRect];
}

// Draw both the segments and the nodes of the given path
- (void) drawPath : (UPFPatternPath*) path
       withArrows : (BOOL) drawArrows
     segmentColor : (UIColor*) segmentColor
   pathNodesColor : (UIColor*) pathNodeColor {
    // Set the segment color, and draw the segments
    [segmentColor set];
    [self drawAllPathSegments : path
                   withArrows : drawArrows];
    [self drawSegmentFromLastPathNodeToLastTouchedPoint];
    
    // Set the path node color, and draw the path nodes
    [pathNodeColor set];
    [self drawAllPathNodes : path];
}

- (void) drawUserInputPath {
    UIColor* segmentColor = self.userInputPathSegmentColor;
    UIColor* nodeColor    = self.userInputPathNodeColor;
    
    // If the path is erroneous, use special colors
    if (self.userInputIsErroneous) {
        segmentColor = self.erroneousPathSegmentColor;
        nodeColor    = self.erroneousPathNodeColor;
    }
    
    [self drawPath : self.userInput.patternPath
        withArrows : NO
      segmentColor : segmentColor
    pathNodesColor : nodeColor];
}

- (void) drawPatternReferenceInputPath {
    // If no pattern reference path is defined, there is nothing to draw
    if ([self.pattern.referenceInputSet isEmpty])
        return;
    
    UPFPatternPath* referencePath = [self.pattern.referenceInputSet getLastAddedInput].patternPath;
    
    UIColor* segmentColor = self.patternReferenceSegmentColor;
    UIColor* nodeColor    = self.patternReferencePathNodeColor;
    
    // If touch input is disabled, make the reference path brighter for a visual hint about that
    if (! self.enableUserInput) {
        CGFloat hue, saturation, brightness, alpha;
        
        [segmentColor getHue : &hue saturation : &saturation brightness : &brightness alpha : &alpha];
        segmentColor = [UIColor colorWithHue : hue
                                   saturation: saturation
                                   brightness: brightness + (1.0 - brightness)/2
                                        alpha: alpha];
        
        [nodeColor getHue : &hue saturation : &saturation brightness : &brightness alpha : &alpha];
        nodeColor    = [UIColor colorWithHue : hue
                                  saturation : saturation
                                  brightness : brightness + (1.0 - brightness)/2
                                       alpha : alpha];
    }
    
    [self drawPath : referencePath
        withArrows : YES
      segmentColor : segmentColor
    pathNodesColor : nodeColor];
}

// --------------------------------------------------------------
// GENERAL DRAWING
// --------------------------------------------------------------

- (void) drawRect : (CGRect) dirtyRect {
    // Draw the pattern and the user input's path
    [self drawAllPatternNodes];
    
    // If the option is set, draw the pattern's reference input path
    if (self.enablePatternReferenceInputPathDrawing)
        [self drawPatternReferenceInputPath];
    
    // If the option is set, draw the user input path
    if (self.enableUserInputPathDrawing)
        [self drawUserInputPath];
    
    // If the option is set, draw the pattern's reference input touch event log
    if (self.enablePatternReferenceInputTouchEventLogDrawing)
        [self drawTouchEventLog : [self.pattern.referenceInputSet getLastAddedInput].touchEventLog];
    
    // If the option is set, draw the user input touch event log
    if (self.enableUserInputTouchEventLogDrawing)
        [self drawTouchEventLog : self.userInput.touchEventLog];
}

@end
