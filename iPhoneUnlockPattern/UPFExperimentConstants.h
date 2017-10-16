//
//  UPFExperimentConstants.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 07/07/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#ifndef UPFExperimentConstants_h
#define UPFExperimentConstants_h

// This file should contain all experimental, simple parameters which are static constants
// It makes it easy to tweak those parameters, by gathering them all in one place

// Note: some other, more complex values can be defined as static class-level properties-like as well
// Here is a short list to find the most important ones:
//
// Reference paths     : UPFExperiment
// Experiment singleton: UPFExperiment
// Root sotrage URLs   : UPFExperiment


// Number of different force profiles which are required, for each reference path
#define EXPERIMENT_NB_FORCE_PROFILES 3

// Number of inputs required for defining a single force profile
#define EXPERIMENT_NB_FORCE_PROFILE_INPUTS 5

// Number of repetetions for user inputs, * for each input mode *
#define EXPERIMENT_NB_USER_INPUTS 10

#endif /* UPFExperimentConstants_h */
