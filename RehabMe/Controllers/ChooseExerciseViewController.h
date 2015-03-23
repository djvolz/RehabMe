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
// Ability to delete videos
// Fix double date thing on graph view
// HUD with number of exercises and number of sets left for day
// create way to cancel out of timer screen
// Menu with view for logging in.
// Make sure tutorial only appears once
// fix skip button for tutorial
// daily motivational quotes
//
//
//
//
// Features:
// Push notifications
// Badges
// Edit text
//
//
// Other:
// Menu with exercises sets
// Talk to therapist
// Therapist select custom exercises
// Pull from my VHI
// Spanish version
// Reading out loud
//
// Maybe:
// Make exercise instructions available while timer is going.
//
// DONE: Custom video instructions
// DONE: Ability to login (possibly automatic user login)
// DONE: Progress over a period of time
// DONE: Add congrats screen
// DONE: redo congrats screen as seperate viewcontroller
// DONE: slider instead of stars
// DONE: Disable swipe touch interaction during focus exercise
// DONE: Timer if applicable
// DONE: Parse data reading from OK and NOPE
// DONE: Text when button is tapped
// DONE: Notification welcome back
// DONE: Rating system after done with cards
// DONE: Fix display of name on cards
// DONE: Tutorial opening screen
// DONE: UPDATE TOTAL SCORE PARAMETER AS UNIVERSAL PARAMETER
///////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "Exercise.h"
#import "ChooseExerciseView.h"
#import "MDCSwipeToChoose.h"
#import "CBZSplashView.h"
#import "TSMessageView.h"
#import "UIColor+HexString.h"
#import "UIBezierPath+Shapes.h"
#import "EAIntroView.h"
#import "CurrentExerciseViewController.h"
#import "CompletionViewContoller.h"
#import "MenuViewController.h"


#define SECONDS_IN_A_DAY    86400
#define SECONDS_IN_AN_HOUR  3600
#define SECONDS_IN_A_MINUTE 60




@interface ChooseExerciseViewController : UIViewController <MDCSwipeToChooseDelegate, TSMessageViewProtocol, EAIntroDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (nonatomic, strong) Exercise *currentExercise;
@property (nonatomic, strong) ChooseExerciseView *frontCardView;
@property (nonatomic, strong) ChooseExerciseView *backCardView;

@property (strong, nonatomic) IBOutlet UIView *view;

- (void)loadDeck;

@end



