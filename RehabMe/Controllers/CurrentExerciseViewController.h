//
//  CurrentExerciseViewController.h
//
//  Created by Dan Volz on 3/7/2015.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ChooseExerciseView.h"
#import "CircularProgressTimerView.h"
#import "UIColor+HexString.h"

@interface CurrentExerciseViewController : UIViewController <MDCSwipeToChooseDelegate>


- (instancetype)initWithExercise:(Exercise *)exercise;

@property (nonatomic, strong) CircularProgressTimerView *circleProgressTimerView;


@end
