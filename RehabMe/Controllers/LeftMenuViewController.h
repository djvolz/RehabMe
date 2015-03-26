//
//  LeftMenuViewController.h
//  RehabMe
//
//  Created by Danny Volz on 3/25/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import <Parse/Parse.h>


//#import "UIViewController+RESideMenu.h"


@interface LeftMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate>

@property (strong, nonatomic)NSString *welcomeString;


@end