//
// ChooseExerciseViewController.m
//
// Copyright (c) 2015 , Dan Volz @djvolz
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ChooseExerciseViewController.h"


static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChooseExerciseViewController ()
@property (nonatomic, strong) NSMutableArray *exercises;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *nopeButton;
@property (nonatomic, strong) CBZSplashView *splashView;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;

@property (nonatomic, strong) PFObject *exerciseObject;
@property (nonatomic, strong) PFObject *exerciseRatingObject;


@end

@implementation ChooseExerciseViewController

@synthesize starRating = _starRating;




#pragma mark - Object Lifecycle

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        // This view controller maintains a list of ChooseExerciseView
//        // instances to display.
//        _exercises = [[self defaultPeople] mutableCopy];
//    }
//    return self;
//}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDeck];
    
    [self setupRatingStars];
    
    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
//    [self constructNopeButton];
//    [self constructLikedButton];
//    [self loginExampleMethod];

}



//- (void)loginExampleMethod {
//    PFUser *user = [PFUser user];
//    user.username = @"Yize";
//    user.password = @"Zhao";
//    user.email = @"contact@rehabme.com";
//
//    // other fields can be set just like with PFObject
//    user[@"phone"] = @"415-392-0202";
//    
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            // Hooray! Let them use the app now.
//        } else {
//            NSString *errorString = [error userInfo][@"error"];
//            // Show the errorString somewhere and let the user try again.
//        }
//    }];
//}



- (void) viewDidAppear:(BOOL)animated {
    [self animateButton];
    
    
    // Show welcome badge notification
    [TSMessage showNotificationInViewController:self
                                           title:NSLocalizedString(@"Welcome back!", nil)
                                        subtitle:NSLocalizedString(@"This uses an image you can define", nil)
                                           image:[UIImage imageNamed:@"NotificationBackgroundSuccessIcon"]
                                            type:TSMessageNotificationTypeSuccess
                                        duration:TSMessageNotificationDurationAutomatic
                                        callback:nil
                                     buttonTitle:nil
                                  buttonCallback:nil
                                      atPosition:TSMessageNotificationPositionTop
                            canBeDismissedByUser:YES];

}

// Constructs splash that splashes green check button that grows across screen
- (void) constructSplashScreen {
    UIImage *icon = [UIImage imageNamed:@"checkButton"];
    UIColor *color = [UIColor greenColor];
    CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:icon backgroundColor:color];
    
    splashView.animationDuration = 1.4;
    
    [self.view addSubview:splashView];
    
    self.splashView = splashView;

}



// Make the reload button pulse
- (void)animateButton {
    CABasicAnimation *pulseAnimation;
    
    pulseAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration = 1.0;
    pulseAnimation.repeatCount = HUGE_VALF;
    pulseAnimation.autoreverses = YES;
    pulseAnimation.fromValue =[NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:0.7];
    [self.reloadButton.layer addAnimation:pulseAnimation forKey:@"animateOpacity"];
    
}

- (void)loadDeck {
    self.starRating.hidden = YES;

    
    // This view controller maintains a list of ChooseExerciseView
    // instances to display.
    _exercises = [[self defaultPeople] mutableCopy];
    
    // Display the first ChooseExerciseView in front. Users can swipe to indicate
    // whether they like or dislike the person displayed.
    self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
    [self.view addSubview:self.frontCardView];
    
    // Display the second ChooseExerciseView in back. This view controller uses
    // the MDCSwipeToChooseDelegate protocol methods to update the front and
    // back views after each user swipe.
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
    
}

- (void) endOfDeck {
    [self constructSplashScreen];
    
    [self.splashView startAnimation];
    
    self.starRating.hidden = NO;
    self.view.backgroundColor = [UIColor greenColor];
}



- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentExercise.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        [self viewDidSwipeLeft];
    } else {
        [self viewDidSwipeRight];
    }

    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(ChooseExerciseView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty.
    _frontCardView = frontCardView;
    self.currentExercise = frontCardView.exercise;
}


- (NSArray *)defaultPeople {
    // It would be trivial to download these from a web service
    // as needed, but for the purposes of this sample app we'll
    // simply store them in memory.
    return @[
        [[Exercise alloc] initWithName:@"CalfRaises"
                               image:[UIImage imageNamed:@"calf_raises"]
                                 count:15
               numberOfSharedFriends:3
             numberOfSharedInterests:2
                      timeRequired:10
                          instructions:@"Bacon ipsum dolor amet chuck elit incididunt alcatra nostrud brisket. Shankle landjaeger beef ribs chicken dolor reprehenderit hamburger cow ham hock jerky pork pork belly in meatball consequat. Leberkas irure in, chicken adipisicing cupim fatback ground round quis frankfurter hamburger. Boudin tenderloin occaecat jowl, tail rump picanha ut alcatra flank esse proident. Prosciutto ut mollit et ground round proident labore kielbasa bacon ipsum tenderloin beef ribs."],

        [[Exercise alloc] initWithName:@"HalfSquats"
                               image:[UIImage imageNamed:@"half_squats"]
                                 count:28
               numberOfSharedFriends:2
             numberOfSharedInterests:6
                      timeRequired:8
                          instructions:@"Lie on back or stomach\nLegs should be straight\n"],

        [[Exercise alloc] initWithName:@"HamstringCurls"
                               image:[UIImage imageNamed:@"hamstring_curls"]
                                 count:14
               numberOfSharedFriends:1
             numberOfSharedInterests:3
                      timeRequired:5
                          instructions:@"do your stuff"],

//        [[Exercise alloc] initWithName:@"HeelCordStretch"
//                               image:[UIImage imageNamed:@"heel_cord_stretch"]
//                                 count:18
//               numberOfSharedFriends:1
//             numberOfSharedInterests:1
//                      timeRequired:20
//                          instructions:@"do your stuff"],
//
//        [[Exercise alloc] initWithName:@"HipAbduction"
//                                 image:[UIImage imageNamed:@"hip_abduction"]
//                                 count:15
//                 numberOfSharedFriends:3
//               numberOfSharedInterests:2
//                          timeRequired:10
//                          instructions:@"do your stuff"],
//
//
//        [[Exercise alloc] initWithName:@"HipAdduction"
//                                 image:[UIImage imageNamed:@"hip_adduction"]
//                                 count:15
//                 numberOfSharedFriends:3
//               numberOfSharedInterests:2
//                          timeRequired:15
//                          instructions:@"do your stuff"],
//
//
//        [[Exercise alloc] initWithName:@"LegExtensions"
//                                 image:[UIImage imageNamed:@"leg_extensions"]
//                                 count:15
//                 numberOfSharedFriends:3
//               numberOfSharedInterests:2
//                          timeRequired:12
//                          instructions:@"do your stuff"],
//
//
//        [[Exercise alloc] initWithName:@"LegPresses"
//                                 image:[UIImage imageNamed:@"leg_presses"]
//                                 count:15
//                 numberOfSharedFriends:3
//               numberOfSharedInterests:2
//                          timeRequired:7
//                          instructions:@"do your stuff"],

    ];
}

- (ChooseExerciseView *)popPersonViewWithFrame:(CGRect)frame {
    if ([self.exercises count] == 0) {
        return nil;
    }

    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };

    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    ChooseExerciseView *personView = [[ChooseExerciseView alloc] initWithFrame:frame
                                                                    person:self.exercises[0]
                                                                   options:options];
    [self.exercises removeObjectAtIndex:0];
    return personView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 100.f;
    CGFloat bottomPadding = 180.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    UIButton *nopeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"xButton"];
    nopeButton.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [nopeButton setImage:image forState:UIControlStateNormal];
    [nopeButton setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
    [nopeButton addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nopeButton];
}

// Create and add the "OK" button.
- (void)constructLikedButton {
    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"checkButton"];
    likeButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [likeButton setImage:image forState:UIControlStateNormal];
    [likeButton setTintColor:[UIColor colorWithRed:29.f/255.f
                                         green:245.f/255.f
                                          blue:106.f/255.f
                                         alpha:1.f]];
    [likeButton addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:likeButton];
}

#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    if(self.exercises.count != 0)
        [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
    else {
        NSLog(@"All done!");
    }

}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    if(self.exercises.count != 0)
        [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
    else {
        NSLog(@"All done!");
    }
}



- (IBAction)pressedReloadButton:(UIButton *)sender {
//    /* wait a beat before animating in */
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    });
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadDeck];
}




#pragma mark - Swipe Actions

- (void)updateParseWithSwipeDecision:(NSString *)decision {
    self.exerciseObject = [PFObject objectWithClassName:@"ExerciseObject"];
    self.exerciseObject[decision] = self.currentExercise.name;
    self.exerciseObject[self.currentExercise.name] = decision;
    
    [self.exerciseObject saveInBackground];
}


- (void)viewDidSwipeRight {
    NSLog(@"You selected %@.", self.currentExercise.name);
    
    double delayInSeconds = 5.0;

    // ignore touch events
    [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
    
    //First allow setup and waiting time to get ready
    [self setupCircularProgressTimerView:(NSInteger)delayInSeconds + 1 withColor:[UIColor yellowColor]];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        //Then actually show the exercise timer
        [self setupCircularProgressTimerView:self.currentExercise.timeRequired withColor:[UIColor greenColor]];
    });
    
    // accept user input again
    [[UIApplication sharedApplication]endIgnoringInteractionEvents];
    
    [self updateParseWithSwipeDecision:@"performed"];
    
    [self checkforEndOfDeck];
    
}

- (void)viewDidSwipeLeft {
    NSLog(@"You noped %@.", self.currentExercise.name);
    
    [self updateParseWithSwipeDecision:@"skipped"];
    
    [self checkforEndOfDeck];
    
}

- (void) checkforEndOfDeck {
    // No more backcard so after completing this swipe is the end of the deck
    if (self.backCardView == nil) {
        [self endOfDeck];
    }
}


#pragma mark - Rating System

- (void)setupRatingStars {
    // Setup control using iOS7 tint Color
    _starRating.backgroundColor  = [UIColor clearColor];
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.maxRating = 5.0;
    _starRating.delegate = self;
    _starRating.horizontalMargin = 15.0;
    _starRating.editable = YES;
    _starRating.rating = 2.5;
    _starRating.displayMode = EDStarRatingDisplayAccurate;
    [_starRating  setNeedsDisplay];
    _starRating.tintColor = [UIColor whiteColor];
    _starRating.hidden = YES;
    [self starsSelectionChanged:_starRating rating:2.5];
    
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    if (self.starRating.hidden == NO) {
        NSString *ratingString = [NSString stringWithFormat:@"%.1f", rating];
        NSLog(@"You rated the exercise as %@.", ratingString);

        
        self.exerciseRatingObject = [PFObject objectWithClassName:@"ExerciseRatingObject"];
        self.exerciseRatingObject[@"Rating"] = ratingString;
        
        [self.exerciseRatingObject saveInBackground];
    }
}


#pragma mark - Circle Timer Progress Bar System

- (void)setupCircularProgressTimerView:(NSInteger)seconds withColor:(UIColor *)color{
    
    CircularProgressTimerView *circleProgressTimerView = [[CircularProgressTimerView alloc] init];
    
    self.circleProgressTimerView = circleProgressTimerView;
    
    
    [self.view insertSubview:circleProgressTimerView aboveSubview:self.frontCardView];
    
    // Set the circleProgressTimerView with the intial time in seconds.
    [self.circleProgressTimerView setTimer:seconds];
    
    [self.circleProgressTimerView setCircleColor:color];
    
    [self.circleProgressTimerView startTimer];
    
}



@end
