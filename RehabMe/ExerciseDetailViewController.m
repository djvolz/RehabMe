//
//  ExerciseDetailViewController.m
//  RehabMe
//
//  Created by Dan Volz on 4/9/15 (at the Istanbul airport).
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "ExerciseDetailViewController.h"

@interface ExerciseDetailViewController ()

@end

@implementation ExerciseDetailViewController

@synthesize exercisePhoto;
@synthesize prepTimeLabel;
@synthesize instructionsTextView;
@synthesize exercise;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:REHABME_GREEN]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"Lato" size:20.0],
                                               NSFontAttributeName,
                                               nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    self.title = exercise.name;
    self.prepTimeLabel.text = [@(exercise.timeRequired) stringValue];
    self.exercisePhoto.file = exercise.imageFile;
    
    NSMutableString *instructionsText = [NSMutableString string];
    for (NSString* instruction in exercise.instructions) {
        [instructionsText appendFormat:@"%@\n", instruction];
    }
    self.instructionsTextView.text = instructionsText;
    
    // Make sure we don't stretch out the image and so it scales correctly.
    self.exercisePhoto.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)viewDidUnload
{
    [self setExercisePhoto:nil];
    [self setPrepTimeLabel:nil];
    [self setInstructionsTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end
