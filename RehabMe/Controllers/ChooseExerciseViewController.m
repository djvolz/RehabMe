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

@property (strong, nonatomic) IBOutlet UIView *view;

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBarItem;

@end

@implementation ChooseExerciseViewController


#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeRehabMe];
    
    rootView = self.navigationController.view;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self checkIfUserIsLoggedIn];
    
    [self cardViewIsBeingShown:YES];
    

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)initializeRehabMe {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:REHABME_GREEN]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"Lato" size:20.0],
                                               NSFontAttributeName,
                                               nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    
    
//    // Show welcome badge notification
//    [TSMessage showNotificationInViewController:self
//                                          title:NSLocalizedString(@"Welcome back!", nil)
//                                       subtitle:NSLocalizedString(@"", nil)
//                                          image:[UIImage imageNamed:@"NotificationBackgroundSuccessIcon"]
//                                           type:TSMessageNotificationTypeSuccess
//                                       duration:3.0//TSMessageNotificationDurationAutomatic
//                                       callback:nil
//                                    buttonTitle:nil
//                                 buttonCallback:nil
//                                     atPosition:TSMessageNotificationPositionTop
//                           canBeDismissedByUser:YES];
    
    
    // Run the PLIST code checking/making
    [self checkOrCreatePLIST];
    
    // Load the deck when the VC loads.
    /* wait a beat before animating in */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDeck];
        
    });
    
}

#pragma mark - Handling PLIST Creation/Existence Check

/* This function is mirrored in EAIntroView.  If this one changes, change that one too. */
- (NSString *)getPathForPLIST {
    //PLIST Variables
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"RehabMePreferences.plist"];
    
    return path;
}

- (void)checkOrCreatePLIST {
    //PLIST Variables
    NSString *path = [self getPathForPLIST];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    
    // PLIST exists
    if ([fileManager fileExistsAtPath: path]) {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    // PLIST does not exist
    else {
        data = [[NSMutableDictionary alloc] init];
        [data setObject: [NSNumber numberWithInt: 0] forKey:@"seenIntro"];
        [data writeToFile: path atomically:YES];
    }
}

#pragma mark - Checking If Intro Seen

- (BOOL)shouldShowIntro {
    //PLIST Variables
    NSString *path = [self getPathForPLIST];
    NSMutableDictionary *savedInfo = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    if ([[savedInfo objectForKey:@"seenIntro"] intValue] == 0) {
        return true;
    } else {
        return false;
    }
}

#pragma mark - Log In


- (void)checkIfUserIsLoggedIn {
    if (![PFUser currentUser]) { // No user logged in
        
        // Display the tutorial if we have not seen it
        if ([self shouldShowIntro]) {
            [self showIntroWithCrossDissolve];
        }
        
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate

        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton;
 
        
        [logInViewController.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rehabme_logo"]]];
        // Make sure we don't stretch out the image and so it scales correctly.
        logInViewController.logInView.logo.contentMode = UIViewContentModeScaleAspectFit;
        logInViewController.logInView.backgroundColor = [UIColor colorWithHexString:REHABME_GREEN];
        
        [logInViewController.logInView.passwordForgottenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        signUpViewController.fields = PFSignUpFieldsDefault;
        
        [signUpViewController.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rehabme_logo"]]];
        // Make sure we don't stretch out the image and so it scales correctly.
        signUpViewController.signUpView.logo.contentMode = UIViewContentModeScaleAspectFit;
        signUpViewController.signUpView.backgroundColor = [UIColor colorWithHexString:REHABME_GREEN];
        
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:NO completion:^{
        }];
    }
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
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



- (void)clearDeck {
    self.frontCardView = nil;
    self.backCardView = nil;
    [self.exercises removeAllObjects];
    [_exercises removeAllObjects];
}

- (void)getExercises {
    if (!self.exercises) {
        self.exercises = [[NSMutableArray alloc] init];
    }
    
    [self.exercises removeAllObjects];
    
    // Only use this code if you are already running it in a background
    // thread, or for testing purposes!
    PFQuery *query = [PFQuery queryWithClassName:@"Exercise"];
    NSArray* queryArray = [query findObjects];
    
    for (PFObject *object in queryArray) {
        Exercise *exercise = [[Exercise alloc] init];
        exercise.name = [object objectForKey:@"name"];
        exercise.displayName = [object objectForKey:@"displayName"];

        exercise.imageFile = [object objectForKey:@"imageFile"];
        exercise.prepTime = [object objectForKey:@"prepTime"];
        exercise.timeRequired = [[object objectForKey:@"timeRequired"] intValue];
        exercise.count = [[object objectForKey:@"count"] intValue];
        exercise.instructions = [object objectForKey:@"instructions"];
        
        [self.exercises addObject:exercise];
    }
    
}

/* Load up the deck from the exercises array */
- (void)loadDeck {
    [self clearDeck];
    
    [self getExercises];
    
    // This view controller maintains a list of ChooseExerciseView
    // instances to display.
//    _exercises = [[self defaultPeople] mutableCopy];

    
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
- (void) cardViewIsBeingShown:(BOOL)hideView {
    
    self.ratingView.hidden = hideView;
    self.beginButton.hidden = !hideView;
}

- (IBAction)didPressSubmitButton:(UIButton *)sender {
    [self cardViewIsBeingShown:YES];
    self.beginButton.hidden = YES;

    
    // Make the reward splash screen
    [self constructSplashScreen];
    
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
    self.exerciseObject.ACL = [PFACL ACLWithUser:[PFUser currentUser]];

    //    self.exerciseObject[self.currentExercise.name] = decision;
    
    [self.exerciseObject saveInBackground];
}


- (void)viewDidSwipeRight {
    NSLog(@"You selected %@.", self.currentExercise.name);
    
    
    
    [self updateParseWithSwipeDecision:@"performed"];
    
    [self updateGameScore];
    
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
        [self cardViewIsBeingShown:NO];
    }
}

- (void) updateGameScore{
    
    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
    [query orderByDescending:@"createdAt"];

    
    //TODO: There has got to be a better way to organize this section. */
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *gameScore, NSError *error) {
        if (!error) {
            // Do something with the returned PFObject in the gameScore variable.

            NSTimeInterval timeSinceCreation   = [gameScore.createdAt timeIntervalSinceDate:[NSDate date]];
            NSTimeInterval timeSinceLastUpdate = [gameScore.updatedAt timeIntervalSinceDate:[NSDate date]];

            
            /* Create a new score every day. */
            if (fabs(timeSinceCreation) > SECONDS_IN_A_DAY) {
                NSLog(@"Created a new GameScore");
                PFObject *gameScore = [PFObject objectWithClassName:@"GameScore"];
                gameScore[@"score"] = @1;
                //        gameScore[@"choice"] = @YES;
                //        gameScore[@"exercise"] = self.currentExercise.name;
                
                gameScore.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                
                [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                            NSLog(@"%@",gameScore.objectId);
                    } else {
                        // There was a problem, check error.description
                    }
                }];
                
                return;
            }


            
            /* Scores can only be updated once every 30 seconds. Troll protection */
            if (fabs(timeSinceLastUpdate) > SECONDS_IN_A_MINUTE/2) {
                NSLog(@"Incrementing GameScore");
                [gameScore incrementKey:@"score"];
                [gameScore saveInBackground];
            } else {
                NSLog(@"Scores can only be updated after an exercise has been performed.");
            }
            
        
        /* This is the first time so setup the gameScore object. */
        } else {
            
            PFObject *gameScore = [PFObject objectWithClassName:@"GameScore"];
            gameScore[@"score"] = @1;
            //        gameScore[@"choice"] = @YES;
            //        gameScore[@"exercise"] = self.currentExercise.name;
            
            gameScore.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"%@",gameScore.objectId);
                } else {
                    // There was a problem, check error.description
                }
            }];
            
        }
        
    }];
    // The InBackground methods are asynchronous, so any code after this will run
    // immediately.  Any code that depends on the query result should be moved
    // inside the completion block above.

}



#pragma mark - Current Exercise View System

- (void)constructCurrentExerciseViewController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    CurrentExerciseViewController *currentExerciseViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"currentExerciseViewController"];
    
    currentExerciseViewController.currentExercise = self.currentExercise;
    
    [self presentViewController:currentExerciseViewController  animated:YES completion:nil];
}

#pragma mark - EAIntroView

- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
        page1.title = @"Hello world";
        page1.desc = @"Hello world";
    page1.bgImage = [UIImage imageNamed:@"bg0"];
//            page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg0"]];
    
//    EAIntroPage *page2 = [EAIntroPage page];
//        page2.title = @"This is page 2";
//        page2.desc = @"Hello world";
//    page2.bgImage = [UIImage imageNamed:@"bg0"];
////        page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg0"]];
//    
//    EAIntroPage *page3 = [EAIntroPage page];
//        page3.title = @"This is page 3";
//        page3.desc = @"Hello world";
//    page3.bgImage = [UIImage imageNamed:@"bg0"];
////        page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg0"]];
//    
//    EAIntroPage *page4 = [EAIntroPage page];
//        page4.title = @"This is page 4";
//        page4.desc = @"Hello world";
//    page4.bgImage = [UIImage imageNamed:@"bg0"];
////        page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg0"]];
//    
//    EAIntroPage *page5 = [EAIntroPage page];
//        page4.title = @"This is page 4";
//        page4.desc = @"Hello world";
//    page5.bgImage = [UIImage imageNamed:@"bg0"];
//    //    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg4"]];
//    
    EAIntroPage *page6 = [EAIntroPage page];
    page6.title = @"Welcome to RehabMe";
    page6.desc = @"Let's get healing!";
    page6.bgImage = [UIImage imageNamed:@"bg0"];
    page6.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rehabme"]];
    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1, page6]];
    [intro setDelegate:self];
    
//    [intro showInView:rootView animateDuration:0.3];
    [[UIApplication sharedApplication].keyWindow addSubview:intro];
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





- (NSArray *)defaultPeople {
    // It would be trivial to download these from a web service
    // as needed, but for the purposes of this sample app we'll
    // simply store them in memory.
    return @[
             [[Exercise_static alloc] initWithName:@"Calf_Raises"
                                      image:[UIImage imageNamed:@"calf_raises"]
                                      count:4
                                displayName:@"Calf Raises"
                               timeRequired:30
                               instructions:@"Main muscles worked:\nGastrocnemius-soleus complex\n\nYou should feel this stretch in your calf and into your heel\n\n• Stand facing a wall with your unaffected leg forward with a slight bend at the knee. Your affected leg is straight and behind you, with the heel flat and the toes pointed in slightly.\n\n• Keep both heels flat on the floor and press your hips forward toward the wall.\n\n• Hold this stretch for 30 seconds and then relax for 30 seconds. Repeat."],
             
             [[Exercise_static alloc] initWithName:@"Standing_Quadriceps_Stretch"
                                      image:[UIImage imageNamed:@"standing_quadriceps_stretch"]
                                      count:2
                                displayName:@"Standing Quadriceps Stretch"
                               timeRequired:30
                               instructions:@"Main muscles worked:\nQuadriceps\n\nYou should feel this stretch in the front of your thigh\n\n• Hold on to the back of a chair or a wall for balance.\n\n• Bend your knee and bring your heel up toward your buttock.\n\n• Grasp your ankle with your hand and gently pull your heel closer to your body.\n\n• Hold this position for 30 to 60 seconds.\n\n• Repeat with the opposite leg."],
             
             [[Exercise_static alloc] initWithName:@"Supine_Hamstring_Stretch"
                                      image:[UIImage imageNamed:@"supine_hamstring_stretch"]
                                      count:2
                                displayName:@"Supine Hamstring Stretch"
                               timeRequired:30
                               instructions:@"Main muscles worked:\nHamstrings\n\nYou should feel this stretch at the back of your thigh and behind your knee\n\n• Lie on the floor with both legs bent.\n\n• Lift one leg off of the floor and bring the knee toward your chest. Clasp your hands behind your thigh below your knee.\n\n• Straighten your leg and then pull it gently toward your head, until you feel a stretch. (If you have difficulty clasping your hands behind your leg, loop a towel around your thigh. Grasp the ends of the towel and pull your leg toward you.)\n\n• Hold this position for 30 to 60 seconds.\n\n• Repeat with the opposite leg."],
             
             [[Exercise_static alloc] initWithName:@"Half_Squats"
                                      image:[UIImage imageNamed:@"half_squats"]
                                      count:10
                                displayName:@"Half Squats"
                               timeRequired:5
                               instructions:@"Main muscles worked:\nQuadriceps, gluteus, hamstrings\n\nYou should feel this exercise at the front and back of your thighs, and your buttocks\n\n• Stand with your feet shoulder distance apart. Your hands can rest on the front of your thighs or reach in front of you. If needed, hold on to the back of a chair or wall for balance.\n\n• Keep your chest lifted and slowly lower your hips about 10 inches, as if you are sitting down into a chair.\n\n• Plant your weight in your heels and hold the squat for 5 seconds.\n\n• Push through your heels and bring your body back up to standing."],
             
             [[Exercise_static alloc] initWithName:@"Hamstring_Curls"
                                      image:[UIImage imageNamed:@"hamstring_curls"]
                                      count:10
                                displayName:@"Hamstring Curls"
                               timeRequired:5
                               instructions:@"Main muscles worked:\nHamstrings\n\nYou should feel this exercise at the back of your thigh\n\n• Hold onto the back of a chair or a wall for balance.\n\n• Bend your affected knee and raise your heel toward the ceiling as far as possible without pain.\n\n• Hold this position for 5 seconds and then relax. Repeat."],
             ];
}



@end
