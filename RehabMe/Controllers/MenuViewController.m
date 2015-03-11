//
//  MenuViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/8/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()  {
    UIView *rootView;
    EAIntroView *_intro;
}
@property (strong, nonatomic) IBOutlet UIView *mainView;

@end

@implementation MenuViewController : UIViewController

- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender {
    // Dismiss this viewcontroller
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Hide the status bar in the menu vie
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
//    rootView = self.navigationController.view;
    rootView = self.mainView;

    [self showIntroWithCrossDissolve];
}


#pragma mark - EAIntroView

- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Hello world";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
//    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1"]];
    
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
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3,page4,page5]];
    [intro setDelegate:self];
    
    [intro showInView:rootView animateDuration:0.3];
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

@end
