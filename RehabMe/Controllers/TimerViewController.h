//
//  TimerViewController.h
//  RehabMe
//
//  Created by Danny Volz on 3/31/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularProgressTimerView.h"
#import "UIColor+HexString.h"

@interface TimerViewController : UIViewController <UIAlertViewDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) CircularProgressTimerView *circleProgressTimerView;
@property (nonatomic, assign) NSUInteger timeRequired;


@end

