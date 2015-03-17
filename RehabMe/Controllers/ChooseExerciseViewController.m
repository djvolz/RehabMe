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

@interface ChooseExerciseViewController () {
    UIView *rootView;
    EAIntroView *_intro;
}
@property (nonatomic, strong) NSMutableArray *exercises;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *nopeButton;
@property (nonatomic, strong) CBZSplashView *splashView;

@property (nonatomic, strong) PFObject *exerciseObject;

@property (strong, nonatomic) IBOutlet UIButton *beginButton;

@property (nonatomic, strong) PFObject *exerciseRatingObject;
@property (strong, nonatomic) NSString *rating;
@property (strong, nonatomic) IBOutlet UISlider *ratingSlider;
@property (weak, nonatomic) IBOutlet UIView *ratingView;

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBarItem;

@end

@implementation ChooseExerciseViewController


#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
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
    
    
    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
    //    [self constructNopeButton];
    //    [self constructLikedButton];
    //    [self loginExampleMethod];
    
    
    // Show welcome badge notification
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Welcome back!", nil)
                                       subtitle:NSLocalizedString(@"", nil)
                                          image:[UIImage imageNamed:@"NotificationBackgroundSuccessIcon"]
                                           type:TSMessageNotificationTypeSuccess
                                       duration:3.0//TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
    
    // Load the deck when the VC loads.
    /* wait a beat before animating in */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDeck];
        
    });
    
    rootView = self.navigationController.view;
    
//    [self showIntroWithCrossDissolve];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.ratingView.hidden = YES;
    self.beginButton.hidden = NO;
}


/* Constructs splash that splashes green check button that grows across screen */
- (void) constructSplashScreen {
    UIImage *icon = [UIImage imageNamed:@"checkButton"];
    
    UIColor *color = [UIColor colorWithHexString:REHABME_GREEN]; //[UIColor greenColor];
    CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:icon backgroundColor:color];
    
    splashView.animationDuration = 1.4;
    
    [self.view addSubview:splashView];
    
    self.splashView = splashView;
    
}

/* Show the menu */
- (IBAction)didTouchMenuButton:(UIButton *)sender {
    //    [self constructCurrentExerciseViewController];
//    [self constructCompletionViewController];
}

/* Load up the deck from the exercises array */
- (void)loadDeck {
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
    
    
    
    
    
    
//    PFObject *gameScore = [PFObject objectWithClassName:@"GameScore"];
//    
//    
//    gameScore[@"score"] = 0;
////    gameScore[@"playerName"] = @"Sean Plott";
////    gameScore[@"cheatMode"] = @NO;
//    [gameScore pinInBackground];
    
    
}

/* Perform the events that occur when you've swiped away all cards in the deck. */
- (void) endOfDeck {
    
    self.ratingView.hidden = NO;
    self.beginButton.hidden = YES;
}

- (IBAction)didPressSubmitButton:(UIButton *)sender {
    // Make the reward splash screen
    [self constructSplashScreen];
    
    self.ratingView.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithHexString:REHABME_GREEN];
    
    
    
    // Execute the reward splash screen
    [self.splashView startAnimationWithCompletionHandler:
    
     ^{
          // Present congrats screen
          [self performSegueWithIdentifier: @"showCompletionViewController" sender: self];
         
         //    [self updateParseWithRatingDecision:self.rating];


          /* wait a beat before animating in */
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [self loadDeck];
              self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.91];
          });
         
     }];

    
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
                                      count:4
                                displayName:@"Calf Raises"
                               timeRequired:30
                               instructions:@"Main muscles worked:\nGastrocnemius-soleus complex\n\nYou should feel this stretch in your calf and into your heel\n\n• Stand facing a wall with your unaffected leg forward with a slight bend at the knee. Your affected leg is straight and behind you, with the heel flat and the toes pointed in slightly.\n\n• Keep both heels flat on the floor and press your hips forward toward the wall.\n\n• Hold this stretch for 30 seconds and then relax for 30 seconds. Repeat."],
             
             [[Exercise alloc] initWithName:@"StandingQuadricepsStretch"
                                      image:[UIImage imageNamed:@"standing_quadriceps_stretch"]
                                      count:2
                                displayName:@"Standing Quadriceps Stretch"
                               timeRequired:30
                               instructions:@"Main muscles worked:\nQuadriceps\n\nYou should feel this stretch in the front of your thigh\n\n• Hold on to the back of a chair or a wall for balance.\n\n• Bend your knee and bring your heel up toward your buttock.\n\n• Grasp your ankle with your hand and gently pull your heel closer to your body.\n\n• Hold this position for 30 to 60 seconds.\n\n• Repeat with the opposite leg."],
             
             [[Exercise alloc] initWithName:@"SupineHamstringStretch"
                                      image:[UIImage imageNamed:@"supine_hamstring_stretch"]
                                      count:2
                                displayName:@"Supine Hamstring Stretch"
                               timeRequired:30
                               instructions:@"Main muscles worked:\nHamstrings\n\nYou should feel this stretch at the back of your thigh and behind your knee\n\n• Lie on the floor with both legs bent.\n\n• Lift one leg off of the floor and bring the knee toward your chest. Clasp your hands behind your thigh below your knee.\n\n• Straighten your leg and then pull it gently toward your head, until you feel a stretch. (If you have difficulty clasping your hands behind your leg, loop a towel around your thigh. Grasp the ends of the towel and pull your leg toward you.)\n\n• Hold this position for 30 to 60 seconds.\n\n• Repeat with the opposite leg."],
             
             [[Exercise alloc] initWithName:@"HalfSquats"
                                      image:[UIImage imageNamed:@"half_squats"]
                                      count:10
                                displayName:@"Half Squats"
                               timeRequired:5
                               instructions:@"Main muscles worked:\nQuadriceps, gluteus, hamstrings\n\nYou should feel this exercise at the front and back of your thighs, and your buttocks\n\n• Stand with your feet shoulder distance apart. Your hands can rest on the front of your thighs or reach in front of you. If needed, hold on to the back of a chair or wall for balance.\n\n• Keep your chest lifted and slowly lower your hips about 10 inches, as if you are sitting down into a chair.\n\n• Plant your weight in your heels and hold the squat for 5 seconds.\n\n• Push through your heels and bring your body back up to standing."],
             
             [[Exercise alloc] initWithName:@"HamstringCurls"
                                      image:[UIImage imageNamed:@"hamstring_curls"]
                                      count:10
                                displayName:@"Hamstring Curls"
                               timeRequired:5
                               instructions:@"Main muscles worked:\nHamstrings\n\nYou should feel this exercise at the back of your thigh\n\n• Hold onto the back of a chair or a wall for balance.\n\n• Bend your affected knee and raise your heel toward the ceiling as far as possible without pain.\n\n• Hold this position for 5 seconds and then relax. Repeat."],
             // [[Exercise alloc] initWithName:@"CalfRaises"
             //                          image:[UIImage imageNamed:@"calf_raises"]
             //                          count:4
             //                    displayName:@"Calf Raises"
             //                   timeRequired:30
             //                   instructions:@"Main muscles worked: Gastrocnemius-soleus complex You should feel this stretch in your calf and into your heel\n\n• Stand facing a wall with your unaffected leg forward with a slight bend at the knee. Your affected leg is straight and behind you, with the heel flat and the toes pointed in slightly.\n\n• Keep both heels flat on the floor and press your hips forward toward the wall.\n\n• Hold this stretch for 30 seconds and then relax for 30 seconds. Repeat."],
             
             //  [[Exercise alloc] initWithName:@"HalfSquats"
             //                           image:[UIImage imageNamed:@"half_squats"]
             //                           count:28
             //                     displayName:@"Half Squats"
             //                    timeRequired:8
             //                    instructions:@"Lie on back or stomach\nLegs should be straight\n"],
             
             //  [[Exercise alloc] initWithName:@"HamstringCurls"
             //                           image:[UIImage imageNamed:@"hamstring_curls"]
             //                           count:14
             //                     displayName:@"Hamstring Curls"
             //                    timeRequired:5
             //                    instructions:@"do your stuff"],
             
             //  [[Exercise alloc] initWithName:@"HeelCordStretch"
             //                           image:[UIImage imageNamed:@"heel_cord_stretch"]
             //                           count:18
             //                     displayName:@"Heel Cord Stretch"
             
             //                    timeRequired:20
             //                    instructions:@"do your stuff"],
             
             //  [[Exercise alloc] initWithName:@"HipAdduction"
             //                           image:[UIImage imageNamed:@"hip_adduction"]
             //                           count:15
             //                     displayName:@"Hip Adduction"
             //                    timeRequired:15
             //                    instructions:@"do your stuff"],
             //  //
             //  //        [[Exercise alloc] initWithName:@"HipAbduction"
             //  //                                 image:[UIImage imageNamed:@"hip_abduction"]
             //  //                                 count:15
             //  //                          timeRequired:10
             //  //                          instructions:@"do your stuff"],
             //  //
             //  //
             
             //  //
             //  //
             //  //        [[Exercise alloc] initWithName:@"LegExtensions"
             //  //                                 image:[UIImage imageNamed:@"leg_extensions"]
             //  //                                 count:15
             //  //                          timeRequired:12
             //  //                          instructions:@"do your stuff"],
             //  //
             //  //
             //  //        [[Exercise alloc] initWithName:@"LegPresses"
             //  //                                 image:[UIImage imageNamed:@"leg_presses"]
             //  //                                 count:15
             //  //                          timeRequired:7
             //  //                          instructions:@"do your stuff"],
             
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
    CGFloat topPadding = 40.f;
    CGFloat bottomPadding = 140.f;
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




- (IBAction)didPressBeginButton:(UIButton *)sender {
    [self constructCurrentExerciseViewController];
}



#pragma mark - Swipe Actions



- (void)updateParseWithSwipeDecision:(NSString *)decision {
    self.exerciseObject = [PFObject objectWithClassName:@"ExerciseObject"];
    self.exerciseObject[decision] = self.currentExercise.name;
    //    self.exerciseObject[self.currentExercise.name] = decision;
    
    [self.exerciseObject saveInBackground];
}


- (void)viewDidSwipeRight {
    NSLog(@"You selected %@.", self.currentExercise.name);
    
    
    
    [self updateParseWithSwipeDecision:@"performed"];
    
    
    [self checkforEndOfDeck];
    
}

- (void)viewDidSwipeLeft {
    NSLog(@"You noped %@.", self.currentExercise.name);
    
    [self updateParseWithSwipeDecision:@"skipped"];
    
    // The animation should trigger after backCardView is nil if the last frontcard was noped.
    [self checkforEndOfDeck];
    
}


- (void) checkforEndOfDeck {
    // No more last card so after completing this swipe is the end of the deck
    if (self.backCardView == nil) {
        [self endOfDeck];
    }
}




#pragma mark - Current Exercise View System

- (void)constructCurrentExerciseViewController {
    CurrentExerciseViewController *currentExerciseViewController = [[CurrentExerciseViewController alloc] initWithExercise:self.currentExercise];
    
    [self presentViewController:currentExerciseViewController
                       animated:YES
                     completion:^{}];
}

#pragma mark - EAIntroView

- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    //    page1.title = @"Hello world";
    //    page1.desc = @"Hello world";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    //        page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    //    page2.title = @"This is page 2";
    //    page2.desc = @"Hello world";
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    //    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg2"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    //    page3.title = @"This is page 3";
    //    page3.desc = @"Hello world";
    page3.bgImage = [UIImage imageNamed:@"bg3"];
    //    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg3"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    //    page4.title = @"This is page 4";
    //    page4.desc = @"Hello world";
    page4.bgImage = [UIImage imageNamed:@"bg4"];
    //    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg4"]];
    
    EAIntroPage *page5 = [EAIntroPage page];
    //    page4.title = @"This is page 4";
    //    page4.desc = @"Hello world";
    page5.bgImage = [UIImage imageNamed:@"bg5"];
    //    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg4"]];
    
    EAIntroPage *page6 = [EAIntroPage page];
    page6.title = @"Welcome to RehabMe";
    page6.desc = @"Let's get healing!";
    page6.bgImage = [UIImage imageNamed:@"bg0"];
    page6.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rehabme"]];
    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3,page4,page5,page6]];
    [intro setDelegate:self];
    
    [intro showInView:rootView animateDuration:0.3];
}

#pragma mark - Rating System
- (IBAction)itemSlider:(UISlider *)itemSlider withEvent:(UIEvent*)e;
{
    UITouch * touch = [e.allTouches anyObject];
    
    if( touch.phase != UITouchPhaseMoved &&
       touch.phase != UITouchPhaseBegan) {
        self.rating = [NSString stringWithFormat:@"Rating: %d",
                       (int)self.ratingSlider.value];
    }
    
}

- (void)updateParseWithRatingDecision:(NSString *)rating {
    NSLog(@"%@", rating);
    
    self.exerciseRatingObject = [PFObject objectWithClassName:@"ExerciseRatingObject"];
    self.exerciseRatingObject[@"Rating"] = rating;
    
    [self.exerciseRatingObject saveInBackground];
}



@end
