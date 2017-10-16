//
//  UserListViewController.h
//  iPhoneUnlockPattern
//
//  Created by Camille Gobert on 26/06/2017.
//  Copyright © 2017 Camille Gobert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UPFExperiment.h"

@interface ExperimentUsersTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

// --------------------------------------------------------------
// PROPERTIES
// --------------------------------------------------------------

@property (readonly) UPFExperiment* experiment;

// --------------------------------------------------------------
// METHODS
// --------------------------------------------------------------

- (void) prepareForSegue : (UIStoryboardSegue *) segue
                  sender : (id) sender;

- (NSInteger) numberOfSectionsInTableView : (UITableView *) tableView;
- (NSInteger) tableView : (UITableView *) tableView
  numberOfRowsInSection : (NSInteger) section;
- (UITableViewCell *) tableView : (UITableView *) tableView
          cellForRowAtIndexPath : (NSIndexPath *) indexPath;


@end
