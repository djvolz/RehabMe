//
//  CircularProgressTimerView.m
//  RehabMe
//
//  Created by Danny Volz on 3/6/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "CircularProgressTimerView.h"

@implementation CircularProgressTimerView : UIView


// Draws the progress circles on top of the already painted backgroud
- (void)drawCircularProgressBarWithMinutesLeft:(NSInteger)minutes secondsLeft:(NSInteger)seconds
{
    // Removing unused view to prevent them from stacking up
    for (id subView in [self subviews]) {
        if ([subView isKindOfClass:[CircularProgressTimer class]]) {
            [subView removeFromSuperview];
        }
    }
    
    // Init our view and set current circular progress bar value
//    CGRect progressBarFrame = CGRectMake(0, 0, 180, 180);
    CGRect progressBarFrame = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = progressBarFrame.size.width;
    CGFloat screenHeight = progressBarFrame.size.height;
    
    progressTimerView = [[CircularProgressTimer alloc] initWithFrame:progressBarFrame];
    
    
    if (circleColor != nil) {
        progressTimerView.circleColor = circleColor;
    } else {
        progressTimerView.circleColor = [UIColor greenColor];
    }
    
    progressTimerView.circleFraction = 60/initialTime;
    
    progressTimerView.backgroundColor = [UIColor whiteColor];

    
    [progressTimerView setCenter:CGPointMake(screenWidth/2, screenHeight/2)];
    [progressTimerView setPercent:seconds];
    if (minutes == 0 && seconds == 0) {
        [progressTimerView setInstanceColor:[UIColor redColor]];
    }
    
    // Here, setting the minutes left before adding it to the parent view
    [progressTimerView setMinutesLeft:minutesLeft];
    [progressTimerView setSecondsLeft:secondsLeft];
    [self addSubview:progressTimerView];
    progressTimerView = nil;
}

- (void)setTimer:(NSInteger)seconds {
    initialTime = seconds;
    globalTimer = seconds;
}

- (void)setCircleColor:(UIColor*)color{
    circleColor = color;
}

- (void)startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateCircularProgressBar)
                                           userInfo:nil
                                            repeats:YES];
    
    
}


- (void)updateCircularProgressBar
{
    // Values to be passed on to Circular Progress Bar
    // Between 0 minutes and 2 hours
    if (globalTimer > 0 && globalTimer <= 1200) {
        globalTimer--;
        minutesLeft = globalTimer / 60;
        secondsLeft = globalTimer % 60;
        
        [self drawCircularProgressBarWithMinutesLeft:minutesLeft secondsLeft:secondsLeft];
        NSLog(@"Time left: %02ld:%02ld", (long)minutesLeft, (long)secondsLeft);
    } else {
        [self drawCircularProgressBarWithMinutesLeft:0 secondsLeft:0];
        [timer invalidate];
        [self removeCircleProgressTimerView];
    }
}

- (void)removeCircleProgressTimerView {
    /* Cancel the timer and remove the view. */
    [timer invalidate];
    [self removeFromSuperview];
}

@end
