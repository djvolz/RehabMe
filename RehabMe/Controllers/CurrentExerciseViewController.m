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
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 10000.f;
    
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    ChooseExerciseView *exerciseView = [[ChooseExerciseView alloc] initWithFrame:self.cardView.bounds
                                                                          person:self.currentExercise
                                                                         options:options];
    
    [self.cardView addSubview:(UIView *)exerciseView];
}

- (IBAction)didTouchBeginButton:(UIBarButtonItem *)sender {
    NSLog(@"Begin exercise.");
    
    [self setupCircularProgressTimerView:self.currentExercise.timeRequired withColor:[UIColor colorWithHexString:@"44DB5E"]];//[UIColor greenColor];

//        double delayInSeconds = 5.0;
    
        //First allow setup and waiting time to get ready
//        [self setupCircularProgressTimerView:(NSInteger)delayInSeconds + 1 withColor:[UIColor yellowColor]];
//    
//
//    
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            //code to be executed on the main queue after delay
//            //Then actually show the exercise timer
//            [self setupCircularProgressTimerView:self.currentExercise.timeRequired withColor:[UIColor colorWithHexString:@"44DB5E"]];//[UIColor greenColor];
//        });
}

- (IBAction)dismissPhoto:(UIBarButtonItem *)sender
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
