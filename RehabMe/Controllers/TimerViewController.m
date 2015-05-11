//
//  TimerViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/31/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController() {
    NSTimer *timer;
    NSInteger secondsLeft;
}
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;



@end

@implementation TimerViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupCircularProgressTimerView:self.timeRequired withColor:[UIColor colorWithHexString:REHABME_GREEN]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Circle Timer Progress Bar System

- (void)setupCircularProgressTimerView:(NSInteger)seconds withColor:(UIColor *)color{
    
    secondsLeft = seconds;
    [self.timerLabel setText:[NSString stringWithFormat:@"%ld",(long)secondsLeft]];

    
    // Set the circleTimer with the intial time in seconds.
    NSDate *initialDate = [NSDate date];
    NSDate *finalDate   = [initialDate dateByAddingTimeInterval:seconds];
    
    self.circularTimer =
    [[CircularTimer alloc] initWithPosition:CGPointMake(0.0f, 0.0f)
                                     radius:kRadius
                             internalRadius:kInternalRadius
                          circleStrokeColor:[UIColor lightGrayColor]
                    activeCircleStrokeColor:color
                                initialDate:initialDate
                                  finalDate:finalDate
                              startCallback:^{
                                  [self startPressed];
                              }
                                endCallback:^{
                                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    [self setupTapGestureRecognizer];
    
    // Center the timer
    self.circularTimer.center = CGPointMake(self.view.frame.size.width  / 2,
                                     self.view.frame.size.height / 2);
    
    [self.view addSubview:self.circularTimer];
}

- (void)setupTapGestureRecognizer{
    UITapGestureRecognizer *cardTapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(didReceiveTapGestureRecognizer:)];
    [self.view addGestureRecognizer:cardTapRecognizer];
}



- (void)didReceiveTapGestureRecognizer:(UITapGestureRecognizer*)sender {
    NSLog(@"Tap");
    
    [self.circularTimer stop];
    
    [timer invalidate];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Timer Label
-(void)startPressed{
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateTimer)
                                                   userInfo:nil
                                                    repeats:YES];
    }
}
-(void)stopPressed{
    [timer invalidate];
    timer = nil;
}
-(void)updateTimer{
    if(secondsLeft > -1) {
        secondsLeft -= 1;
        [self.timerLabel setText:[NSString stringWithFormat:@"%ld",(long)secondsLeft]];
    }
    else
        [timer invalidate];
    
}


@end