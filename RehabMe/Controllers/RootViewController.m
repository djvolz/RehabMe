//
//  RootViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/25/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "RootViewController.h"
#import "LeftMenuViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor grayColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;

    self.bouncesHorizontally = YES;
    
    self.panGestureEnabled = YES;
    self.panFromEdge = YES;
    self.parallaxEnabled = YES;
    
    self.scaleContentView = NO;
    self.scaleBackgroundImageView = NO;
    self.scaleMenuView = NO;
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuViewController"];
//    self.backgroundImage = [UIImage imageNamed:@"rehabme"];
    
//    http://www.color-hex.com/color/3bb45d
    self.view.backgroundColor = [UIColor colorWithHexString:@"1d5a2e"];
    
    self.delegate = self;
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end
