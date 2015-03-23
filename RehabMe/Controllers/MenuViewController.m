//
//  MenuViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/8/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;




@end

@implementation MenuViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateLabelWithUserInfo];
}

- (void)clearStorage {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString  *filePath = documentsURL.path;

    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator* directoryEnumberator = [fileManager enumeratorAtPath:filePath];
    NSError* error = nil;
    BOOL result;
    
    NSString* file;
    while (file = [directoryEnumberator nextObject]) {
        result = [fileManager removeItemAtPath:[filePath stringByAppendingPathComponent:file] error:&error];
        if (!result && error) {
            NSLog(@"oops: %@", error);
        }
    }
    
    [self showSuccessfulDeleteAlert];
}


- (void)updateLabelWithUserInfo {
    if ([PFUser currentUser]) {
        // If the user is logged in, show their name in the welcome label.
        
        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            // If user is linked to Twitter, we'll use their Twitter screen name
            self.welcomeLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Welcome @%@!", nil), [PFTwitterUtils twitter].screenName];
            
        } else if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            // If user is linked to Facebook, we'll use the Facebook Graph API to fetch their full name. But first, show a generic Welcome label.
            self.welcomeLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Welcome!", nil)];
            
            // Create Facebook Request for user's details
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                // This is an asynchronous method. When Facebook responds, if there are no errors, we'll update the Welcome label.
                if (!error) {
                    NSString *displayName = result[@"name"];
                    if (displayName) {
                        self.welcomeLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), displayName];
                    }
                }
            }];
            
        } else {
            // If user is linked to neither, let's use their username for the Welcome label.
            self.welcomeLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [PFUser currentUser].username];
            
        }
        
    } else {
        self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
    }
}


- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender {
    // Dismiss this viewcontroller
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didPressDeleteVideosButton:(UIButton *)sender {
    [self clearStorage];
}

// Hide the status bar in the menu vie
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Alert View

- (void) showSuccessfulDeleteAlert {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Videos Deleted" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    
    [alertView show];
}

// Offer to record video if one hasn't already been created
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    } else {
        //other action
    }
}



@end
