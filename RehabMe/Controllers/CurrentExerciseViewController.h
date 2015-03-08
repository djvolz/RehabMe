//
//  CurrentExerciseViewController.m.h
//  CurrentExerciseViewController.m
//
//  Created by Dan Volz on 3/7/2015.
//

#import <UIKit/UIKit.h>
#import "ChooseExerciseView.h"

@interface CurrentExerciseViewController : UIViewController <MDCSwipeToChooseDelegate>


- (instancetype)initWithExercise:(Exercise *)exercise;

@end
