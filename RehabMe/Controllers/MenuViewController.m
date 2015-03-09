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

@implementation MenuViewController : UIViewController

- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender {
    // Dismiss this viewcontroller
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Hide the status bar in the menu vie
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
