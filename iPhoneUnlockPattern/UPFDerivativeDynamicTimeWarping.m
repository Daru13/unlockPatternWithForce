//
//  UPFDynamicTimeWarping.m
//  TouchpadUnlockPattern
//
//  Created by Camille Gobert on 21/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFDerivativeDynamicTimeWarping.h"
#import "UPFInputMatchingAlgorithm.h"
#import "UPFPattern.h"
#import "UPFPatternInput.h"

@implementation UPFDerivativeDynamicTimeWarping

+ (float) getMatchingScoreOfInput : (UPFPatternInput*) input
                      withPattern : (UPFPattern*)      pattern {
    
    NSLog(@"Derivative DTW started with %d input events and %d ref events",
          input.touchEventLog.nbLoggedEvents, [pattern.referenceInputSet getLastAddedInput].touchEventLog.nbLoggedEvents);
    
    // If any of the logs are empty, immediately return 0
    if ([input.touchEventLog isEmpty]
    ||  [pattern.referenceInputSet isEmpty])
        return 0;
    
    // Set up some useful variables
    UPFTouchEventLog* inputEventLog     = input.touchEventLog;
    UPFTouchEventLog* referenceEventLog = [pattern.referenceInputSet getLastAddedInput].touchEventLog;
    
    // Includes one additional line and one additional column (for a simpler recursion)
    int nbLines   = inputEventLog.nbLoggedEvents;
    int nbColumns = referenceEventLog.nbLoggedEvents;
    
    // Create arrays for DERIVED force values for both event logs, and fill them accordingly
    // Those will actually be the sequences used by the DTW algorithm (below)
    double* inputDerivedForces = malloc((inputEventLog.nbLoggedEvents - 1) * sizeof(double));
    assert(inputDerivedForces != NULL);
    
    for (unsigned int i = 1; i < inputEventLog.nbLoggedEvents; i++) {
        inputDerivedForces[i - 1] = [inputEventLog getTouchEventAt : i - 1].force
                                       - [inputEventLog getTouchEventAt : i    ].force;
    }
    
    double* referenceForceDifferentials = malloc((referenceEventLog.nbLoggedEvents - 1) * sizeof(double));
    assert(referenceForceDifferentials != NULL);
    
    for (unsigned int j = 1; j < referenceEventLog.nbLoggedEvents; j++) {
        referenceForceDifferentials[j - 1] = [referenceEventLog getTouchEventAt : j - 1].force
                                           - [referenceEventLog getTouchEventAt : j    ].force;
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
    
/*
    for (unsigned int i = 1; i < nbLines; i++)
        distanceMatrix[i][0] = distanceMatrix[i - 1][0] + inputForceDifferentials[i];
    for (unsigned int j = 1; j < nbColumns; j++)
        distanceMatrix[0][j] = distanceMatrix[0][j - 1] + referenceForceDifferentials[j];
*/
    
    // Fill the matrix with the DTW optimization function
    for (int i = 1; i < nbLines; i++) {
        for (int j = 1/*MAX(1, i - ABS(nbLines - nbColumns))*/; j < nbColumns/*MIN(nbColumns, i + ABS(nbLines - nbColumns))*/; j++) {
            // The cost at (i, j) is the absolute value of the difference of force differentials at resp. indexes i and j
            double absoluteDerivedForcesDifference = fabs(inputDerivedForces[i - 1] - referenceForceDifferentials[j - 1]);
            absoluteDerivedForcesDifference *= absoluteDerivedForcesDifference;
            
            distanceMatrix[i][j] = absoluteDerivedForcesDifference
                                 + MIN(distanceMatrix[i - 1][j - 1],
                                       MIN(distanceMatrix[i][j - 1],
                                           distanceMatrix[i - 1][j]));
            
            // NSLog(@"distanceMatrix[%d][%d] = %lf (asb. diff: %lf)", i, j, distanceMatrix[i][j], absoluteForceDifferentialDifference);
        }
    }
    
    NSLog(@"Derivative DTW finished: value at (%d, %d) is %lf",
          nbLines - 1, nbColumns - 1,
          distanceMatrix[nbLines - 1][nbColumns - 1]);
    NSLog(@"——— score with sqrt: %lf, score with max: %lf ———",
          distanceMatrix[nbLines - 1][nbColumns - 1] / sqrt(nbLines*nbLines + nbColumns*nbColumns),
          distanceMatrix[nbLines - 1][nbColumns - 1] / ((double) MAX(nbLines, nbColumns)));
    
    // Free the distance matrix
    for (unsigned int i = 0; i < nbLines; i++)
         free(distanceMatrix[i]);
    free(distanceMatrix);
    
    // Free the derived arrays
    free(inputDerivedForces);
    free(referenceForceDifferentials);
    
    return 0.5;
}

+ (BOOL) isInputMatching : (UPFPatternInput*) input
             withPattern : (UPFPattern*)      pattern {
    return true;
}

@end
