//
//  CurrentExerciseViewController.m
//
//  Created by Dan Volz on 3/7/2015.
//

#import "CurrentExerciseViewController.h"

@interface CurrentExerciseViewController ()

@property (nonatomic, strong) Exercise *currentExercise;
@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (nonatomic) NSInteger test;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

- (IBAction)playbackButton:(UIBarButtonItem *)sender;

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
//        if ([gesture isKindOfClass:UIPanGestureRecognizer.class]) {
            [exerciseView removeGestureRecognizer:gesture];
//        }
    }
    
    
    [self.cardView addSubview:(UIView *)exerciseView];
}

- (IBAction)didTouchBeginButton:(UIBarButtonItem *)sender {
    
    [self setupCircularProgressTimerView:self.currentExercise.timeRequired
                               withColor:[UIColor colorWithHexString:REHABME_GREEN]];
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

#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // grab our movie URL
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    
    // save it to the documents directory
    NSURL *fileURL = [self grabFileURL:[NSString stringWithFormat:@"%@.mov",self.currentExercise.name]];
    NSData *movieData = [NSData dataWithContentsOfURL:chosenMovie];
    [movieData writeToURL:fileURL atomically:YES];
    
    // save it to the Camera Roll
//    UISaveVideoAtPathToSavedPhotosAlbum([chosenMovie path], nil, nil, nil);
    
    // and dismiss the picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (NSURL*)grabFileURL:(NSString *)fileName {
    
    // find Documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    // append a file name to it
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
    
    return documentsURL;
}


- (void)recordVideo {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        picker.mediaTypes = mediaTypes;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)playbackButton:(UIBarButtonItem *)sender {
    
    // pick a video from the documents directory
    NSURL *video = [self grabFileURL:[NSString stringWithFormat:@"%@.mov",self.currentExercise.name]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:video.path];

    
    if (fileExists) {
        // create a movie player view controller
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc]initWithContentURL:video];
        [controller.moviePlayer prepareToPlay];
        [controller.moviePlayer play];
        
        
        // and present it
        [self presentMoviePlayerViewControllerAnimated:controller];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"No file found at path: %@", video.path]);
        [self showNoFileAlert];
    }
    
}

#pragma mark - Alert View

- (void) showNoFileAlert {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"No video found" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Record Video", nil];
    
    [alertView show];
}

// Offer to record video if one hasn't already been created
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    } else {
        //record video pressed
        [self recordVideo];
    }
}

@end
