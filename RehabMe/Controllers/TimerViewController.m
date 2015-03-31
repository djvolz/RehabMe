//
//  TimerViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/31/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController()

@end

@implementation TimerViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupCircularProgressTimerView:30 withColor:[UIColor colorWithHexString:REHABME_GREEN]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Circle Timer Progress Bar System

- (void)setupCircularProgressTimerView:(NSInteger)seconds withColor:(UIColor *)color{
    
    CircularProgressTimerView *circleProgressTimerView = [[CircularProgressTimerView alloc] init];
    
    self.circleProgressTimerView = circleProgressTimerView;
    
    [self setupTapGestureRecognizer];
    
    
    [self.view addSubview:circleProgressTimerView];
    
    // Set the circleProgressTimerView with the intial time in seconds.
    [self.circleProgressTimerView setTimer:seconds];
    
    [self.circleProgressTimerView setCircleColor:color];
    
    [self.circleProgressTimerView startTimer];
    
}

- (void)setupTapGestureRecognizer{
    UITapGestureRecognizer *cardTapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(didReceiveTapGestureRecognizer:)];
    [self.view addGestureRecognizer:cardTapRecognizer];
}



- (void)didReceiveTapGestureRecognizer:(UITapGestureRecognizer*)sender {
    NSLog(@"Tap");
    
    [self.circleProgressTimerView removeCircleProgressTimerView];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end