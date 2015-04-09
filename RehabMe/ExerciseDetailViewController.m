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
    
    self.title = exercise.name;
    self.prepTimeLabel.text = exercise.prepTime;
    self.exercisePhoto.file = exercise.imageFile;
    
    NSMutableString *ingredientText = [NSMutableString string];
    for (NSString* ingredient in exercise.ingredients) {
        [ingredientText appendFormat:@"%@\n", ingredient];
    }
    self.instructionsTextView.text = ingredientText;
    
}

- (void)viewDidUnload
{
    [self setExercisePhoto:nil];
    [self setPrepTimeLabel:nil];
    [self setInstructionsTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
