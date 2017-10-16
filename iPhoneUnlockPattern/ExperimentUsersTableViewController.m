//
//  UserListViewController.m
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 26/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExperimentUsersTableViewController.h"
#import "UserSessionsTableViewController.h"
#import "UPFExperiment.h"
#import "UPFExperimentUser.h"
#import "UPFExperimentSession.h"

// ----------------------------------------------------------------- Internal interface ---

@interface ExperimentUsersTableViewController ()

@property (readwrite) UPFExperiment* experiment;

@end


// -------------------------------------------------------------- Actual implementation ---

@implementation ExperimentUsersTableViewController

// --------------------------------------------------------------
// VIEW LIFECYCLE CALLBACKS
// --------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // View parameters
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set the shared experiment instance as the view controller experiment
    self.experiment = [UPFExperiment sharedExperiment];
/*
    // Add dummy users for testing purposes
    UPFExperimentUser* testUser1 = [UPFExperimentUser createUserWithId : 123
                                                              mainHand : MAIN_HAND_RIGHT];
    UPFExperimentUser* testUser2 = [UPFExperimentUser createUserWithId : 6665687
                                                              mainHand : MAIN_HAND_LEFT];
    UPFExperimentUser* testUser3 = [UPFExperimentUser createUserWithId : 424242
                                                              mainHand : MAIN_HAND_AMBIDEXTROUS];
    
    UPFExperimentSession* testSession = [UPFExperimentSession createSessionWithNumber : 1
                                                                               userId : testUser1.userId
                                                                        mainInputMode : SESSION_INPUT_MODE_SINGLE_HAND];
    [testUser1 addSession : testSession];
    
    
    [self.experiment addUser : testUser1];
    [self.experiment addUser : testUser2];
    [self.experiment addUser : testUser3];
*/    
    NSLog(@"Table view controller did load, with experiment %@", self.experiment);
}

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear : animated];
    
    // Reload the source data, in case a user has been added
    [self.tableView reloadData];
}

// --------------------------------------------------------------
// SEGUE CALLBACK
// --------------------------------------------------------------

- (void) prepareForSegue : (UIStoryboardSegue*) segue
                  sender : (id) sender {
    // If it is the experiment users -> user sessions segue,
    // set the selected user in the to-be-displayed session table view's controller
    if (! [segue.identifier isEqualToString : @"SelectUserSegue"])
        return;
    
    UserSessionsTableViewController* userSessionsTableViewController = segue.destinationViewController;
    
    long userIndex                       = self.tableView.indexPathForSelectedRow.row;
    UPFExperimentUser* selectedUser      = self.experiment.users[userIndex];
    userSessionsTableViewController.user = selectedUser;
    
    NSLog(@"In SelectUserSegue, user (%@) has been set for %@",
          selectedUser, userSessionsTableViewController);
}

// Allow (and prepare) unwinding to this view controller
- (IBAction) prepareForUnwindToExperimentUsersTableView : (UIStoryboardSegue *) segue {
    NSLog(@"Prepare unwind to ForceProfileInputStepVC");
    
    [self.tableView reloadData];
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
    return self.experiment.users.count;
}

// Answer cell request from a TableView
- (UITableViewCell *) tableView : (UITableView *) tableView
          cellForRowAtIndexPath : (NSIndexPath *) indexPath {
    // Get an existing cell if available, or create a fresh one otherwise
    static NSString* cellIdentifier = @"ExperimentUserCell";
    
    UITableViewCell* tableViewCell = [tableView dequeueReusableCellWithIdentifier : cellIdentifier
                                                                     forIndexPath : indexPath];
    if (tableViewCell == nil)
        tableViewCell = [[UITableViewCell alloc] initWithStyle : UITableViewCellStyleValue1
                                               reuseIdentifier : cellIdentifier];
    
    // Get the user data for the given index
    NSInteger userIndex  = [indexPath row];
    UPFExperimentUser* user = [self.experiment.users objectAtIndex : userIndex];
    
    // Set the style of the cell's text
    // tableViewCell.textLabel.font = [UIFont boldSystemFontOfSize : 17];
    
    // Populate the cell, and return it
    tableViewCell.textLabel.text       = [NSString stringWithFormat : @"User %lu",
                                          user.userId];
/*
    tableViewCell.detailTextLabel.text = [NSString stringWithFormat : @"%d session%@",
                                          (int) user.sessions.count, (user.sessions.count > 1 ? @"s" : @"")];
*/
    tableViewCell.detailTextLabel.text = [UPFExperimentUser handednessToString : user.mainHand];
    
    return tableViewCell;
}

// Handle user deletion from the TableView
- (void) tableView : (UITableView*) tableView
commitEditingStyle : (UITableViewCellEditingStyle) editingStyle
 forRowAtIndexPath : (NSIndexPath*) indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the user from the data source
        [self.experiment removeUserAtIndex : (unsigned int) indexPath.row];
        
        // Visually remove the related row from the table view
        [tableView deleteRowsAtIndexPaths : @[indexPath] withRowAnimation : UITableViewRowAnimationFade];
    }
}

@end
