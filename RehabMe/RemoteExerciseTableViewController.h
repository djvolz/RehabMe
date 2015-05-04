//
//  ExerciseTableViewController.h
//  RehabMe
//
//  Created by Dan Volz on 5/2/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "ExerciseDetailViewController.h"
#import "Exercise.h"
#import "UIColor+HexString.h"

@interface RemoteExerciseTableViewController : PFQueryTableViewController

@end
