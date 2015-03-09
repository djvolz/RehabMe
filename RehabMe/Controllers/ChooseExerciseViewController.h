//
// ChooseExerciseViewController.h
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

///////////////////////////////////////////////////////////////////////////////
//////////////////////      TODO        ///////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//
// MVP:
//
//
// Ability to login
// Menu with view for logging in.
//
// DONE: Disable swipe touch interaction during focus exercise
// DONE: Timer if applicable
// DONE: Parse data reading from OK and NOPE
// DONE: Text when button is tapped
// DONE: Notification welcome back
// DONE: Rating system after done with cards
// DONE: Fix display of name on cards
//
// Maybe:
// Make exercise instructions available while timer is going.
//
// Features:
// Push notifications
// Badges
// Edit text
// HUD with number of exercises and number of sets left for day
// Gif pictorial instruction instead of still picture
// Menu with exercises sets
// Progress over the a period of time
// Custom videos/pictures
//
//
// Other:
// Talk to therapist
// Therapist select custom exercises
// Pull from my VHI
// Spanish version
// Reading out loud
//
///////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Exercise.h"
#import "ChooseExerciseView.h"
#import "MDCSwipeToChoose.h"
#import "CBZSplashView.h"
#import "TSMessageView.h"
#import "UIColor+HexString.h"
#import "UIBezierPath+Shapes.h"
#import "EDStarRating.h"
#import "CurrentExerciseViewController.h"



@interface ChooseExerciseViewController : UIViewController <MDCSwipeToChooseDelegate, TSMessageViewProtocol, EDStarRatingProtocol>


@property (nonatomic, strong) Exercise *currentExercise;
@property (nonatomic, strong) ChooseExerciseView *frontCardView;
@property (nonatomic, strong) ChooseExerciseView *backCardView;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIButton *reloadButton;




@end



