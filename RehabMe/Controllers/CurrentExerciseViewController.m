//
//  CurrentExerciseViewController.m
//
//  Created by Dan Volz on 3/7/2015.
//

#import "CurrentExerciseViewController.h"

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
    
    [self constructChooseExerciseView];
    
    
    
}

- (void)constructChooseExerciseView {
    // If the panning gesture does get enabled we want to make it impossible
    // for the card to be swiped off screen.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    
    // Good luck swiping a million pixels across. Lol
    options.threshold = 1000000.f;
    
    
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    ChooseExerciseView *exerciseView = [[ChooseExerciseView alloc] initWithFrame:self.cardView.bounds
                                                                          person:self.currentExercise
                                                                         options:options];
    //Have the instuctions be displayed upon loading the card.
    [exerciseView showInstuctions:nil];
    
    // Remove the pan gesture from the exerciseView.
    //  (It's confusing to new users to have it be available but unused)
    for (UIGestureRecognizer *gesture in exerciseView.gestureRecognizers) {
        if ([gesture isKindOfClass:UIPanGestureRecognizer.class]) {
            [exerciseView removeGestureRecognizer:gesture];
        }
    }
    
    
    [self.cardView addSubview:(UIView *)exerciseView];
}

- (IBAction)didTouchBeginButton:(UIBarButtonItem *)sender {
    NSLog(@"Begin exercise.");
    
    //    [self setupCircularProgressTimerView:self.currentExercise.timeRequired
    //                               withColor:[UIColor colorWithHexString:REHABME_GREEN]];
    
    double delayInSeconds = 4.0;
    
    //First allow setup and waiting time to get ready
    [self setupCircularProgressTimerView:(NSInteger)delayInSeconds
                               withColor:[UIColor yellowColor]];
    
    // Put up a delay so the exercise timer happens after the get ready timer
    // Subtracting one second from the delay allows for the view loading to overlap
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (delayInSeconds - 1) * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self setupCircularProgressTimerView:self.currentExercise.timeRequired withColor:[UIColor colorWithHexString:REHABME_GREEN]];
    });
}

- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Circle Timer Progress Bar System

- (void)setupCircularProgressTimerView:(NSInteger)seconds withColor:(UIColor *)color{
    
    CircularProgressTimerView *circleProgressTimerView = [[CircularProgressTimerView alloc] init];
    
    self.circleProgressTimerView = circleProgressTimerView;
    
    
    [self.view insertSubview:circleProgressTimerView aboveSubview:self.cardView];
    
    // Set the circleProgressTimerView with the intial time in seconds.
    [self.circleProgressTimerView setTimer:seconds];
    
    [self.circleProgressTimerView setCircleColor:color];
    
    [self.circleProgressTimerView startTimer];
    
}

@end
