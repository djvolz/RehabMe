//
//  MenuViewController.h
//  RehabMe
//
//  Created by Danny Volz on 3/25/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "MenuViewController.h"

#define NUMBER_OF_SECTIONS 5
#define HEIGHT_FOR_ROW     54

@interface MenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.welcomeString = @"Welcome!";
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                               (self.view.frame.size.height - HEIGHT_FOR_ROW * NUMBER_OF_SECTIONS) / 2.0f,
                                                                               self.view.frame.size.width, HEIGHT_FOR_ROW * NUMBER_OF_SECTIONS)
                                                              style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"chooseExerciseViewController"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"completionViewContoller"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 2:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"videoTableViewController"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
            
        case 3:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"exerciseTableViewController"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"chooseExerciseViewController"]]
                                                         animated:NO];
            [self.sideMenuViewController hideMenuViewController];
            
            [PFUser logOut];
            break;

        default:
            break;
    }
}

//
//- (NSString *)updateLabelWithUserInfo {
//    __block NSString *welcomeString = @"";
//    
//    if ([PFUser currentUser]) {
//        // If the user is logged in, show their name in the welcome label.
//        
//        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
//            // If user is linked to Twitter, we'll use their Twitter screen name
//            welcomeString =[NSString stringWithFormat:NSLocalizedString(@"Welcome @%@!", nil), [PFTwitterUtils twitter].screenName];
//            
//        } else if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//            // If user is linked to Facebook, we'll use the Facebook Graph API to fetch their full name. But first, show a generic Welcome label.
//            welcomeString =[NSString stringWithFormat:NSLocalizedString(@"Welcome!", nil)];
//            
//            // Create Facebook Request for user's details
//            FBRequest *request = [FBRequest requestForMe];
//            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                // This is an asynchronous method. When Facebook responds, if there are no errors, we'll update the Welcome label.
//                if (!error) {
//                    NSString *displayName = result[@"name"];
//                    if (displayName) {
//                        welcomeString = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), displayName];                    }
//                }
//            }];
//            
//        } else {
//            // If user is linked to neither, let's use their username for the Welcome label.
//            welcomeString =[NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [PFUser currentUser].username];
//            
//        }
//        
//    } else {
//        welcomeString = NSLocalizedString(@"Not logged in", nil);
//    }
//    
//    return welcomeString;
//}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_FOR_ROW;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return NUMBER_OF_SECTIONS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    
    NSArray *titles = @[@"Home", @"Progress", @"Videos", @"Exercises", @"Log Out"];
    NSArray *images = @[@"IconHome", @"IconCalendar", @"video_camera_white", @"barbell_white", @"IconProfile"/*,@"IconEmpty"*/];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}

@end
