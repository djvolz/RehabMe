//
//  CurrentExerciseViewController.h
//
//  Created by Dan Volz on 3/7/2015.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "TimerViewController.h"
#import "ChooseExerciseView.h"
#import "UIColor+HexString.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>



#define RECORD_ALERT   101
#define SETTINGS_ALERT 201
#define OTHER_ALERT    301

@import MediaPlayer;


@interface CurrentExerciseViewController : UIViewController <MDCSwipeToChooseDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) Exercise *currentExercise;



@end
