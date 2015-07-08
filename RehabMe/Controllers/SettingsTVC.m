//
//  SettingsTVC.m
//  RehabMe
//
//  Created by Dan Volz on 7/7/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "SettingsTVC.h"


@interface SettingsTVC ()
@end

@implementation SettingsTVC {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:REHABME_GREEN]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"Lato" size:20.0],
                                               NSFontAttributeName,
                                               nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
}

@end
