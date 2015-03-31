//
//  CircularProgressTimerView.h
//  RehabMe
//
//  Created by Danny Volz on 3/6/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularProgressTimer.h"

@interface CircularProgressTimerView : UIView
{
    UIColor *circleColor;
    NSTimer *timer;
    NSInteger initialTime;
    NSInteger globalTimer;
    NSInteger counter;
    NSInteger minutesLeft;
    NSInteger secondsLeft;
    UIRefreshControl *refreshControl;
    CircularProgressTimer *progressTimerView;
}

- (void)startTimer;
- (void)setTimer:(NSInteger)seconds;
- (void)setCircleColor:(UIColor*)color;

- (void)removeCircleProgressTimerView;


@end
