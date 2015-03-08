//
//  CurrentExerciseViewController.m
//  CurrentExerciseViewController.m
//
//  Created by Dan Volz on 3/7/2015.
//

#import "CurrentExerciseViewController.h"

static const UIView *holderView;

@interface CurrentExerciseViewController ()

@property (nonatomic, strong) Exercise *currentExercise;
@property (strong, nonatomic) IBOutlet UIView *cardView;


@end

@implementation CurrentExerciseViewController

- (instancetype)initWithExercise:(Exercise *)exercise{
    if (self = [super init]) {
        self.currentExercise = exercise;
    }
    
    return self;
}



- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 10000.f;
    
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    ChooseExerciseView *personView = [[ChooseExerciseView alloc] initWithFrame:self.cardView.bounds
                                                                        person:self.currentExercise
                                                                       options:options];
    
    [self.cardView addSubview:(UIView *)personView];
}

- (IBAction)dismissPhoto:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
