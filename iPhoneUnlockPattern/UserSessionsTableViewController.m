//
//  UserSessionsTableViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 26/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import "UserSessionsTableViewController.h"
#import "CreateSessionViewController.h"
#import "StepViewController.h"
#import "UPFExperimentUser.h"
#import "UPFExperimentSession.h"

@implementation UserSessionsTableViewController {
    UPFExperimentSession* selectedSession;
}

// --------------------------------------------------------------
// VIEW LIFECYCLE CALLBACKS
// --------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // View parameters
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : YES];
    
    // Reload the source data, in case a new session has been finished
    [self.tableView reloadData];
    
    // Reset the selected session
    selectedSession = nil;
}

// --------------------------------------------------------------
// SEGUE CALLBACK
// --------------------------------------------------------------

- (void) prepareForCreateSessionSegue : (UIStoryboardSegue*) segue
                                      : (id) sender {
    CreateSessionViewController* createSessionViewController = segue.destinationViewController;
    
    // Set the related user of the session creation view's controller
    createSessionViewController.relatedUser = self.user;
    
    // Also pre-set the session number, according to the number of sessions of the currently selected user
    unsigned long nextSessionNumber = self.user.sessions.count + 1L;
    createSessionViewController.sessionNumberValue         = (unsigned int) nextSessionNumber;
    createSessionViewController.sessionNumberHasBeenPreset = YES;
    
    NSLog(@"In CreateSessionSegue, user (%@) has been set for %@",
          self.user, createSessionViewController);
}

- (void) prepareForStartSessionSegue : (UIStoryboardSegue*) segue
                                     : (UITableViewCell*) selectedCell {
    // Get (+ save?) the selected session
    NSIndexPath* selectedCellIndexPath = [self.tableView indexPathForCell : selectedCell];
    selectedSession = self.user.sessions[selectedCellIndexPath.row];
    
    // Get the first view of the destination navigation controller
    UINavigationController* segueDestination   = segue.destinationViewController;
    StepViewController*     stepViewController = (StepViewController*) segueDestination.topViewController;
    
    // Only set the reference session here, shared by all steps afterwards
    // The rest will by intialized by the steps themselves (and their inter-segues)
    stepViewController.relatedSession = selectedSession;
    
    NSLog(@"In StartSessionSegue, session (%@) has been set for %@",
          selectedSession, stepViewController);
}

// Delegate each segue handling to different methods, one per segue identifier
- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender {
    if ([segue.identifier isEqualToString : @"CreateSessionSegue"])
        [self prepareForCreateSessionSegue : segue : sender];
    
    else if ([segue.identifier isEqualToString : @"StartSessionSegue"])
        [self prepareForStartSessionSegue : segue : (UITableViewCell*) sender];
}

#pragma mark - Table view data source
// --------------------------------------------------------------
// TABLE VIEW DATA SOURCE
// --------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView : (UITableView *) tableView {
    return 1;
}

- (NSInteger) tableView : (UITableView *) tableView
  numberOfRowsInSection : (NSInteger) section {
    // Since there is only one section, the section parameters is unused
    return self.user.sessions.count;
}

// Answer cell requests from a TableView
- (UITableViewCell *) tableView : (UITableView *) tableView
          cellForRowAtIndexPath : (NSIndexPath *) indexPath {
    // Get an existing cell if available, or create a fresh one otherwise
    static NSString* cellIdentifier = @"UserSessionCell";
    
    UITableViewCell* tableViewCell = [tableView dequeueReusableCellWithIdentifier : cellIdentifier
                                                                     forIndexPath : indexPath];
    if (tableViewCell == nil)
        tableViewCell = [[UITableViewCell alloc] initWithStyle : UITableViewCellStyleSubtitle
                                               reuseIdentifier : cellIdentifier];
    
    // Get the session data for the given index
    NSInteger userIndex  = [indexPath row];
    UPFExperimentSession* session = [self.user.sessions objectAtIndex : userIndex];
    
    // Set the cell state depending on the session state
    if (session.isFinished) {
        tableViewCell.accessoryType          = UITableViewCellAccessoryCheckmark;
        tableViewCell.userInteractionEnabled = NO;
    }
    else {
        tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        tableViewCell.userInteractionEnabled = YES;
    }
    
    // Populate the cell, and return it
    tableViewCell.textLabel.text       = [NSString stringWithFormat : @"Session %d",
                                          session.number];
    tableViewCell.detailTextLabel.text = [NSString stringWithFormat : @"%@ — %@",
                                          [UPFExperimentSession inputModeAsString  : session.mainInputMode],
                                          [UPFExperimentSession stepsOrderAsString : session.stepsOrder]];
    
    return tableViewCell;
}

// Handle session deletion from the TableView
- (void) tableView : (UITableView*) tableView
commitEditingStyle : (UITableViewCellEditingStyle) editingStyle
 forRowAtIndexPath : (NSIndexPath*) indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the session from the data source
        [self.user removeSessionAtIndex : (unsigned int) indexPath.row];
        
        // Visually remove the related row from the table view
        [tableView deleteRowsAtIndexPaths : @[indexPath] withRowAnimation : UITableViewRowAnimationFade];
    }
}

// TODO: remove, useless?
// Handle session selection from the TableView
- (void)      tableView : (UITableView *) tableView
didSelectRowAtIndexPath : (NSIndexPath *) indexPath {
    selectedSession = self.user.sessions[indexPath.row];
}

@end
