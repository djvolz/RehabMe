//
//  StorageManagementViewController.h
//  RehabMe
//
//  Created by Danny Volz on 3/22/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HexString.h"

@interface VideoTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
