//
//  MenuViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/8/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
}


- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender {
    // Dismiss this viewcontroller
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Hide the status bar in the menu vie
- (BOOL)prefersStatusBarHidden
{
    return YES;
}



//- (void)loginExampleMethod {
//    PFUser *user = [PFUser user];
//    user.username = @"Yize";
//    user.password = @"Zhao";
//    user.email = @"contact@rehabme.com";
//
//    // other fields can be set just like with PFObject
//    user[@"phone"] = @"415-392-0202";
//
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            // Hooray! Let them use the app now.
//        } else {
//            NSString *errorString = [error userInfo][@"error"];
//            // Show the errorString somewhere and let the user try again.
//        }
//    }];
//}

@end
