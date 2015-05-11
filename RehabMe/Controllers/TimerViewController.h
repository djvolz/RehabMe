//
//  TimerViewController.h
//  RehabMe
//
//  Created by Danny Volz on 3/31/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularTimer.h"
#import "UIColor+HexString.h"

#define kRadius 150
#define kInternalRadius 75


@interface TimerViewController : UIViewController <UIAlertViewDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) CircularTimer *circularTimer;

@property (nonatomic, assign) NSUInteger timeRequired;


@end

