//
//  UPFExperiment.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 23/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UPFExperiment.h"
#import "UPFPatternPath.h"

// ----------------------------------------------------------------- Internal interface ---

@interface UPFExperiment ()

@property (readwrite) NSMutableArray<UPFExperimentUser*>* users;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation UPFExperiment

// --------------------------------------------------------------
// SINGLETON EXPERIMENT (ACCESS + CREATION)
// --------------------------------------------------------------

+ (instancetype) sharedExperiment {
    static UPFExperiment*  globalExperimentInstance = nil;
    static dispatch_once_t singleInitToken;
    
    dispatch_once(&singleInitToken, ^{
        // TODO: load an existing experiment if possible
        if ([UPFExperiment fileExistsAtPath : [UPFExperiment pathToExperimentSerializedDataFile].path]) {
            globalExperimentInstance = [UPFExperiment unserialize];
        }
        else {
            globalExperimentInstance = [UPFExperiment createEmptyExperiment];
            [globalExperimentInstance serialize];
        }
        
        NSLog(@"Global experiment created: %@ (%lu users)", globalExperimentInstance, globalExperimentInstance.users.count);
    });
    
    return globalExperimentInstance;
}

// --------------------------------------------------------------
// GLOBAL PATHS (ACCESS + CREATION)
// --------------------------------------------------------------

+ (NSURL*) pathToExperimentSerializedDataFile {
    static NSURL*          globalPathToExperimentSerializedDataFile = nil;
    static dispatch_once_t singleInitToken;
    
    dispatch_once(&singleInitToken, ^{
        // Path do the app's 'Document' directory
        NSFileManager* mainFileManager = [NSFileManager defaultManager];
        NSURL* urlToAppDocuments = [[mainFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        // Append experiment data subfolder's name
        globalPathToExperimentSerializedDataFile = [urlToAppDocuments URLByAppendingPathComponent : @"app-serialized-data"];
        
        NSLog(@"pathToExperimentSerializedDataFile created: %@", globalPathToExperimentSerializedDataFile);
    });
    
    return globalPathToExperimentSerializedDataFile;
}

+ (NSURL*) pathToExperimentUsersFolder {
    static NSURL*          globalPathToExperimentUsersFolder = nil;
    static dispatch_once_t singleInitToken;
    
    dispatch_once(&singleInitToken, ^{
        // Path do the app's 'Document' directory
        // Path do the app's 'Document' directory
        NSFileManager* mainFileManager = [NSFileManager defaultManager];
        NSURL* urlToAppDocuments = [[mainFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        // Append experiment data subfolder's name
        globalPathToExperimentUsersFolder = [urlToAppDocuments URLByAppendingPathComponent : @"experiment-user-data"];
        
        NSLog(@"pathToExperimentUsersFolder created: %@", globalPathToExperimentUsersFolder);
    });
    
    return globalPathToExperimentUsersFolder;
}

// --------------------------------------------------------------
// GLOBAL PATTERN PATHS (ACCESS + CREATION)
// --------------------------------------------------------------

+ (NSArray<UPFPatternPath*>*) listOfReferencePaths {
    static NSArray<UPFPatternPath*>* globalListOfReferencePaths = nil;
    static dispatch_once_t           singleInitToken;

    dispatch_once(&singleInitToken, ^{
        // Build all the exeperiment reference paths
        
        // Path 1: horizontal line pattern (3 nodes, no angle)
        NSArray<UPFPatternNode*>* path1Nodes = @[
            [UPFPatternNode createNodeAt : 1 : 0],
            [UPFPatternNode createNodeAt : 1 : 1],
            [UPFPatternNode createNodeAt : 1 : 2]
        ];
        
        // Path 2: top-left hand corner pattern (5 nodes, 1 angle)
        NSArray<UPFPatternNode*>* path2Nodes = @[
            [UPFPatternNode createNodeAt : 0 : 2],
            [UPFPatternNode createNodeAt : 0 : 1],
            [UPFPatternNode createNodeAt : 0 : 0],
            [UPFPatternNode createNodeAt : 1 : 0],
            [UPFPatternNode createNodeAt : 2 : 0]
        ];
        
        // Path 3: Z pattern (7 nodes, 2 angles)
        NSArray<UPFPatternNode*>* path3Nodes = @[
            [UPFPatternNode createNodeAt : 0 : 0],
            [UPFPatternNode createNodeAt : 0 : 1],
            [UPFPatternNode createNodeAt : 0 : 2],
            [UPFPatternNode createNodeAt : 1 : 1],
            [UPFPatternNode createNodeAt : 2 : 0],
            [UPFPatternNode createNodeAt : 2 : 1],
            [UPFPatternNode createNodeAt : 2 : 2]
        ];
        
        // Path 4: vertical zig-zag pattern (9 nodes, 4 angles)
        NSArray<UPFPatternNode*>* path4Nodes = @[
            [UPFPatternNode createNodeAt : 0 : 0],
            [UPFPatternNode createNodeAt : 1 : 0],
            [UPFPatternNode createNodeAt : 2 : 0],
            [UPFPatternNode createNodeAt : 0 : 1],
            [UPFPatternNode createNodeAt : 1 : 1],
            [UPFPatternNode createNodeAt : 2 : 1],
            [UPFPatternNode createNodeAt : 0 : 2],
            [UPFPatternNode createNodeAt : 1 : 2],
            [UPFPatternNode createNodeAt : 2 : 2]
        ];

        // Add them all to the global list of paths
        globalListOfReferencePaths = @[
            [UPFPatternPath createPathFromListOfNodes : path1Nodes],
            [UPFPatternPath createPathFromListOfNodes : path2Nodes],
            [UPFPatternPath createPathFromListOfNodes : path3Nodes],
            [UPFPatternPath createPathFromListOfNodes : path4Nodes]
        ];
        
        NSLog(@"globalListOfReferenecPaths created: %@", globalListOfReferencePaths);
    });
    
    
    return globalListOfReferencePaths;
}

// --------------------------------------------------------------
// USER LIST EDITING
// --------------------------------------------------------------

- (BOOL) userIdIsAvailable : (UPFUserId) userId {
    for (UPFExperimentUser* user in self.users)
        if (user.userId == userId)
            return false;
    
    return true;
}

- (void) addUser : (UPFExperimentUser*) user {
    [self.users addObject : user];
}

- (void) removeUserAtIndex : (unsigned int) index {
    [self.users removeObjectAtIndex : index];
}

// --------------------------------------------------------------
// FILESYSTEM OPERATIONS
// --------------------------------------------------------------

+ (BOOL) fileExistsAtPath : (NSString*) path {
    NSFileManager* mainFileManager = [NSFileManager defaultManager];

    BOOL isDirectory;
    BOOL fileExists = [mainFileManager fileExistsAtPath : path
                                            isDirectory : &isDirectory];
    return fileExists && (! isDirectory);
}

+ (BOOL) directoryExistsAtPath : (NSString*) path {
    NSFileManager* mainFileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    BOOL fileExists = [mainFileManager fileExistsAtPath : path
                                            isDirectory : &isDirectory];
    return fileExists && isDirectory;
}

// If the directory creation failed, throw an exception named 'DirectoryCreationFailureException'
+ (void) createDirectoriesOfPath : (NSString*) path {
    NSFileManager* mainFileManager = [NSFileManager defaultManager];
    
    NSError* error = nil;
    BOOL success = [mainFileManager createDirectoryAtPath : path
                              withIntermediateDirectories : YES
                                               attributes : nil
                                                    error : &error];
    
    // Check if the directory creation worked well, and raise an exception if not
    if (! success)
        @throw [NSException exceptionWithName : @"DirectoryCreationFailureException"
                                       reason : [error localizedFailureReason]
                                     userInfo : nil];
}

// If an intermediate directory creation failed, throw an exception named 'DirectoryCreationFailureException'
// If the file creation failed, throw an exception named 'FileCreationFailureException'
+ (void) createFileAndIntermediateDirectoriesAtPath : (NSString*) path
                                        withContent : (NSData*) content {
    NSFileManager* mainFileManager = [NSFileManager defaultManager];
    
    // Get the file parent directory's path
    NSString* parentDirectoryPath = [path stringByDeletingLastPathComponent];
    
    // Check if it already exists, and create the path if not (incl. intermediate directories)
    BOOL parentDirectoryExists = [UPFExperiment directoryExistsAtPath : parentDirectoryPath];
    if (! parentDirectoryExists)
        [UPFExperiment createDirectoriesOfPath : parentDirectoryPath];
    
    // Finally, create the file (if it fails, raise the related exception)
    // Note: if the file already exists, it is overwritten!
    [mainFileManager createFileAtPath : path
                             contents : content
                           attributes : nil];
}

+ (NSData*) getFileDataAtPath : (NSString*) path {
    NSFileManager* mainFileManager = [NSFileManager defaultManager];
    return [mainFileManager contentsAtPath : path];
}

// --------------------------------------------------------------
// SERIALIZE
// --------------------------------------------------------------

- (NSData*) getAsSerializedData {
    NSLog(@"before serial");
    NSMutableData* data = [NSMutableData dataWithCapacity : 1024];
    
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData : data];
    archiver.outputFormat = NSPropertyListBinaryFormat_v1_0;
    
    [archiver encodeObject : self
                    forKey : @"Experiment"];
    [archiver finishEncoding];
    NSLog(@"after serial");
    
    return data;
}

- (void) serializeInFile : (NSString*) path {
    NSData* experimentData = [self getAsSerializedData];
    [UPFExperiment createFileAndIntermediateDirectoriesAtPath : path
                                                  withContent : experimentData];
}

- (void) serialize {
    [self serializeInFile : [UPFExperiment pathToExperimentSerializedDataFile].path];
}

// --------------------------------------------------------------
// UNSERIALIZE
// --------------------------------------------------------------

+ (instancetype) unserializeFromData : (NSData*) data {
    NSLog(@"before unserial");
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData : data];
    
    UPFExperiment* experiment = [unarchiver decodeObjectForKey: @"Experiment"];
    NSLog(@"after unserial");
    
    return experiment;
}

+ (instancetype) unserializeFromFileAtPath : (NSString*) path {
    NSData* serializedExperimentData = [UPFExperiment getFileDataAtPath : path];
    return [UPFExperiment unserializeFromData : serializedExperimentData];
}

+ (instancetype) unserialize {
    return [UPFExperiment unserializeFromFileAtPath : [UPFExperiment pathToExperimentSerializedDataFile].path];
}

// --------------------------------------------------------------
// DATA EXPORT
// --------------------------------------------------------------

- (NSString*) getUserFolderNameForIndex : (unsigned int) index {
    return [NSString stringWithFormat : @"user-%ld", self.users[index].userId];
}

- (void) exportDataInFolderAtPath : (NSString*) path {
    // Export all users data, one folder per user
    for (unsigned int i = 0; i < self.users.count; i++) {
        UPFExperimentUser* currentUser = self.users[i];
        NSString* pathToCurrentUserFolder = [path stringByAppendingPathComponent : [self getUserFolderNameForIndex : i]];
        
        [currentUser exportDataInFolderAtPath : pathToCurrentUserFolder];
    }
}

// Export experiment data in default folder
- (void) exportData {
    [self exportDataInFolderAtPath : [UPFExperiment pathToExperimentUsersFolder].path];
}

// --------------------------------------------------------------
// BUILDER
// --------------------------------------------------------------

// Builder method
+ (UPFExperiment*) createEmptyExperiment {
    UPFExperiment* newExperiment = [UPFExperiment new];
    
    if (newExperiment) {
        newExperiment.users = [NSMutableArray<UPFExperimentUser*> array];
    }
    
    return newExperiment;
}

// --------------------------------------------------------------
// CODING AND DECODING
// --------------------------------------------------------------

- (void) encodeWithCoder : (NSCoder*) aCoder {
    [aCoder encodeObject : self.users forKey : @"users"];
    
    // Also encode 'static' variables for additional information on iPhone file location?
    // Note, though, that those fields are useless for decoding purposes
    [aCoder encodeObject : [UPFExperiment pathToExperimentSerializedDataFile] forKey : @"pathToExperimentSerializedDataFile"];
    [aCoder encodeObject : [UPFExperiment pathToExperimentUsersFolder]        forKey : @"pathToExperimentUsersFolder"];
}

- (instancetype) initWithCoder : (NSCoder*) aDecoder {
    self = [super init];
    
    if (self) {
        _users = [aDecoder decodeObjectForKey : @"users"];
    }
    
    return self;
}

@end
