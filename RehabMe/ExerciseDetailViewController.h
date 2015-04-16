//
//  ExerciseDetailViewController.h
//  RehabMe
//
//  Created by Dan Volz on 4/9/15 (at the Istanbul airport).
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "UIColor+HexString.h"

@interface ExerciseDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet PFImageView *exercisePhoto;
@property (weak, nonatomic) IBOutlet UILabel *prepTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextView;

@property (nonatomic, strong) Exercise *exercise;

@end
