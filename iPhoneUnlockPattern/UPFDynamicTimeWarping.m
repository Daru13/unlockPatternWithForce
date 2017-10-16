//
//  UPFDynamicTimeWarping2.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 22/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFDynamicTimeWarping.h"
#import "UPFInputMatchingAlgorithm.h"
#import "UPFPattern.h"
#import "UPFPatternInput.h"

@implementation UPFDynamicTimeWarping

+ (float) getMatchingScoreOfInput : (UPFPatternInput*) input
                      withPattern : (UPFPattern*)      pattern {
    
    NSLog(@"Regular DTW started with %d input events and %d ref events",
          input.touchEventLog.nbLoggedEvents, [pattern.referenceInputSet getLastAddedInput].touchEventLog.nbLoggedEvents);
    
    // If any of the logs are empty, immediately return 0
    if ([input.touchEventLog isEmpty]
    ||  [pattern.referenceInputSet isEmpty])
        return 0;
    
    // Set up some useful variables
    UPFTouchEventLog* inputEventLog     = input.touchEventLog;
    UPFTouchEventLog* referenceEventLog = [pattern.referenceInputSet getLastAddedInput].touchEventLog;
    
    // Includes one additional line and one additional column (for a simpler recursion)
    int nbLines   = 1 + inputEventLog.nbLoggedEvents;
    int nbColumns = 1 + referenceEventLog.nbLoggedEvents;
    
    // Create arrays for RAW force values for both event logs, and fill them accordingly
    // Those will actually be the sequences used by the DTW algorithm (below)
    double* inputRawForces = malloc(inputEventLog.nbLoggedEvents * sizeof(double));
    assert(inputRawForces != NULL);
    
    for (unsigned int i = 0; i < inputEventLog.nbLoggedEvents; i++) {
        inputRawForces[i] = [inputEventLog getTouchEventAt : i].force;
    }
    
    double* referenceRawForces = malloc(referenceEventLog.nbLoggedEvents * sizeof(double));
    assert(referenceRawForces != NULL);
    
    for (unsigned int j = 0; j < referenceEventLog.nbLoggedEvents; j++) {
        referenceRawForces[j] = [referenceEventLog getTouchEventAt : j].force;
    }
    
    // Allocate and initialize to 0 the DTW distance matrix
    double** distanceMatrix = malloc(nbLines * sizeof(double*));
    assert(distanceMatrix != NULL);
    
    for (unsigned int i = 0; i < nbLines; i++) {
        distanceMatrix[i] = malloc(nbColumns * sizeof(double));
        assert(distanceMatrix[i] != NULL);
        
        for (unsigned int j = 0; j < nbColumns; j++)
            distanceMatrix[i][j] = INFINITY;
    }
    
    // Set the origin cell (at [0, 0]) to 0 to init the recursion
    distanceMatrix[0][0] = 0;
    
    // Fill the matrix with the DTW optimization function
    for (int i = 1; i < nbLines; i++) {
        for (int j = 1/*MAX(1, i - ABS(nbLines - nbColumns))*/; j < nbColumns/*MIN(nbColumns, i + ABS(nbLines - nbColumns))*/; j++) {
            // The cost at (i, j) is the absolute value of the difference of force differentials at resp. indexes i and j
            double absoluteForceDifferentialDifference = fabs(inputRawForces[i - 1] - referenceRawForces[j - 1]);
            //absoluteForceDifferentialDifference *= absoluteForceDifferentialDifference;
            
            distanceMatrix[i][j] = absoluteForceDifferentialDifference
                                 + MIN(distanceMatrix[i - 1][j - 1],
                                       MIN(distanceMatrix[i][j - 1],
                                           distanceMatrix[i - 1][j]));
            
            // NSLog(@"distanceMatrix[%d][%d] = %lf (asb. diff: %lf)", i, j, distanceMatrix[i][j], absoluteForceDifferentialDifference);
        }
    }
    
    NSLog(@"Regular DTW finished: value at (%d, %d) is %lf",
          nbLines - 1, nbColumns - 1,
          distanceMatrix[nbLines - 1][nbColumns - 1]);
    NSLog(@"——— score with sqrt: %lf, score with max: %lf ———",
          distanceMatrix[nbLines - 1][nbColumns - 1] / sqrt(nbLines*nbLines + nbColumns*nbColumns),
          distanceMatrix[nbLines - 1][nbColumns - 1] / ((double) MAX(nbLines, nbColumns)));
    
    // Free the distance matrix
    for (unsigned int i = 0; i < nbLines; i++)
        free(distanceMatrix[i]);
    free(distanceMatrix);
    
    // Free the raw force arrays
    free(inputRawForces);
    free(referenceRawForces);
    
    return 0.5;
}

+ (BOOL) isInputMatching : (UPFPatternInput*) input
             withPattern : (UPFPattern*)      pattern {
    return true;
}

@end
