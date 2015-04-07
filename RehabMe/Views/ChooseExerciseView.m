//
// ChooseExerciseView.m
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

#import "ChooseExerciseView.h"
#import "ImageLabelView.h"
#import "Exercise.h"

static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;
static const CGFloat infoHeight = 75.f;


@interface ChooseExerciseView ()
@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ImageLabelView *clockImageLabelView;
@property (nonatomic, strong) ImageLabelView *barbellImageLabelView;
@property (nonatomic, strong) ImageLabelView *cameraImageLabelView;
@property (nonatomic, strong) UITextView *instructionsView;

@end

@implementation ChooseExerciseView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                       person:(Exercise *)exercise
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _exercise = exercise;
        self.imageView.image = _exercise.image;

        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.autoresizingMask = self.autoresizingMask;

        [self constructInformationView];
        
        // Make the imageView background white.
        self.imageView.backgroundColor = [UIColor whiteColor];
        
        /* This resizes the imageView after the image has been loaded to ensure the
         * informationView doesn't cover up the image. */
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                          infoHeight,//self.imageView.frame.origin.y,
                                          self.imageView.frame.size.width,
                                          
                                          // The information bottomHeight
                                          self.imageView.frame.size.height - infoHeight);
        
        // Make sure we don't stretch out the image and so it scales correctly.
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        
//        // A tap gesture so you can see the instructions if you tap the card.
//        UITapGestureRecognizer *cardTapRecognizer = [[UITapGestureRecognizer alloc]
//                                                     initWithTarget:self
//                                                     action:@selector(showInstuctions:)];
//        [self addGestureRecognizer:cardTapRecognizer];

        
    }
    return self;
}

#pragma mark - Internal Methods

- (NSURL*)grabFileURL:(NSString *)fileName {
    
    // find Documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    // append a file name to it
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
    
    return documentsURL;
}

- (void)constructInformationView {
    CGRect topFrame = CGRectMake(0,
                                    0,//CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    infoHeight);
    _informationView = [[UIView alloc] initWithFrame:topFrame];
    _informationView.backgroundColor = [UIColor whiteColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];

    [self constructNameLabel];
    [self constructClockImageLabelView];
    [self constructBarbellImageLabelView];
    [self constructInformationTextViewView];
    
    // pick a video from the documents directory
    NSURL *video = [self grabFileURL:[NSString stringWithFormat:@"%@.mov", self.exercise.name]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:video.path];
    
    if (fileExists) {
        [self constructCameraImageLabelView];
    }

}

- (void)constructNameLabel {
    CGFloat leftPadding = 17.f;
    CGFloat topPadding = 17.f;
    CGRect frame = CGRectMake(leftPadding,
                              topPadding,
                              floorf(CGRectGetWidth(_informationView.frame)/2),
                              CGRectGetHeight(_informationView.frame) - topPadding);
    _nameLabel = [[UILabel alloc] initWithFrame:frame];
    _nameLabel.text = [NSString stringWithFormat:@"%@", _exercise.displayName];
//    _nameLabel.lineBreakMode = YES;
    _nameLabel.numberOfLines = 2;
    [_nameLabel setFont:[UIFont systemFontOfSize:20]];
    [_informationView addSubview:_nameLabel];
}

- (void)constructClockImageLabelView {
    CGFloat rightPadding = 10.f;
    UIImage *image = [UIImage imageNamed:@"clock"];
    _clockImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetWidth(_informationView.bounds) - rightPadding
                                                      image:image
                                                       text:[NSString stringWithFormat:@"%@", @(_exercise.timeRequired)]];
    [_informationView addSubview:_clockImageLabelView];
}

- (void)constructBarbellImageLabelView {
    UIImage *image = [UIImage imageNamed:@"barbell"];
    _barbellImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_clockImageLabelView.frame)
                                                         image:image
                                                          text:[NSString stringWithFormat:@"%@", @(_exercise.count)]];
    [_informationView addSubview:_barbellImageLabelView];
}

- (void)constructCameraImageLabelView {
    UIImage *image = [UIImage imageNamed:@"video_camera"];
    _cameraImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_barbellImageLabelView.frame)
                                                       image:image
                                                        text:[NSString stringWithFormat:@"1"]];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchCameraLabel)];
//    [_cameraImageLabelView addGestureRecognizer:tap];
//    _cameraImageLabelView.userInteractionEnabled = YES;
    
    [_informationView addSubview:_cameraImageLabelView];
}

- (void)didTouchCameraLabel {
    // pick a video from the documents directory
    NSURL *video = [self grabFileURL:[NSString stringWithFormat:@"%@.mov", _exercise.name]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:video.path];
    
    
    if (fileExists) {
        // create a movie player view controller
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc]initWithContentURL:video];
        [controller.moviePlayer prepareToPlay];
        [controller.moviePlayer play];
        
        
        // and present it
        [self addSubview:controller.view];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"No file found at path: %@", video.path]);
    }

}



- (void)constructInformationTextViewView {
    CGRect frame = CGRectMake(0,
                              0,
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame));
    self.instructionsView = [[UITextView alloc] initWithFrame:frame];
    [self.instructionsView setBackgroundColor: [UIColor colorWithRed:200.0 green:200.0 blue:200.0 alpha:0.95]];
    [self.instructionsView setTextColor: [UIColor blackColor]];
    [self.instructionsView setFont:[UIFont fontWithName:@"Helvetica Neue" size:24.0f]];
    self.instructionsView.text = [NSString stringWithFormat:@"%@\n\nSets: %i\nTime: %i s\n\n%@",
                                  _exercise.displayName,
                                  (int)_exercise.count,
                                  (int)_exercise.timeRequired,
                                  _exercise.instructions];
    self.instructionsView.editable = NO;
    self.instructionsView.hidden = YES;
    [self addSubview:self.instructionsView];

}

- (void)showInstuctions:(UITapGestureRecognizer*)sender {
    if (self.instructionsView.hidden) {
        self.instructionsView.hidden = NO;
    } else {
        self.instructionsView.hidden = YES;
    }
}

- (ImageLabelView *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text {
    CGRect frame = CGRectMake(x - ChoosePersonViewImageLabelWidth,
                              0,
                              ChoosePersonViewImageLabelWidth,
                              CGRectGetHeight(_informationView.bounds));
    ImageLabelView *view = [[ImageLabelView alloc] initWithFrame:frame
                                                           image:image
                                                            text:text];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return view;
}

@end
