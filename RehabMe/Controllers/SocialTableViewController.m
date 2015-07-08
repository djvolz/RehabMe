//
//  SocialTableViewController.m
//  RehabMe
//
//  Created by Dan Volz on 7/7/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "SocialTableViewController.h"


@interface SocialTableViewController ()

@end

@implementation SocialTableViewController {
    
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"_User";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"username";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}


- (void)viewDidLoad
{
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable:)
                                                 name:@"refreshTable"
                                               object:nil];
}


- (void)refreshTable:(NSNotification *) notification
{
    // Reload the exercises
    [self loadObjects];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTable" object:nil];
}



- (PFQuery *)queryForTable
{
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"friends"];
    PFQuery *query = [relation query];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
    }
    
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"userCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    // Configure the cell
    PFFile *thumbnail = [object objectForKey:@"imageFile"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
    thumbnailImageView.image = [UIImage imageNamed:@"placeholder"];
    thumbnailImageView.file = thumbnail;
    [thumbnailImageView loadInBackground];
    
    // Make sure we don't stretch out the image and so it scales correctly.
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Create the text label
    //TODO: make sure it fits if device screen isn't wide enough
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:101];
    nameLabel.text = [object objectForKey:@"username"];
    //    nameLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"order"]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    
    /* Check for any existing requests between the two users. */
    NSString *friendRequestClassName = @"FriendRequest";
    
    //Below is the user that the current user would like to remove from their friends list
    PFUser *selectedUser = [self.objects objectAtIndex:indexPath.row];
    
    /* Current user made original request. */
    PFQuery *iRequest = [PFQuery queryWithClassName:friendRequestClassName];
    [iRequest whereKey:@"from" equalTo:[PFUser currentUser]];
    [iRequest whereKey:@"to" equalTo:selectedUser];
    
    /* Selected user made original request. */
    PFQuery *youRequest = [PFQuery queryWithClassName:friendRequestClassName];
    [youRequest whereKey:@"to" equalTo:[PFUser currentUser]];
    [youRequest whereKey:@"from" equalTo:selectedUser];
    
    PFQuery *friendRequestsQuery = [PFQuery orQueryWithSubqueries:@[iRequest,youRequest]];
    
    NSArray *friendRequests  = [friendRequestsQuery findObjects];
    
    /* This first if statement shouldn't be able to happen. */
    if ([friendRequests count] > 1) {
        NSLog(@"Hmm, somehow there is more than one friend request.");
        return;
    } else /*if ([friendRequests count] == 1)*/ {
        PFObject *existingRequest = [friendRequests firstObject];
        
        /* This is all handled in cloud code now. */
        /******************************************/
        
        //        /* Check if user is already friends with selectedUser. */
        //        /* (This assumes that friendRequest objects are never deleted. Alternatively
        //         *  and more slowly I could search through the list of current friends
        //         *  a user already has, but this way kills two birds with one stone
        //         *  when I am already checking for current pending requests.
        //         */
        //        if ([existingRequest[@"status"] isEqualToString:@"accepted"]) {
        //            [existingRequest deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //                if (error) {
        //                    NSLog(@"Error: %@", [error userInfo][@"error"]);
        //                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to delete exercise.", nil) message:NSLocalizedString(@"", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        //                }
        //                [self refreshTable:nil];
        //            }];
        //        }
        
        
        [PFCloud callFunctionInBackground:@"removeFriendToFriendsRelation" withParameters:@{@"friendRequest" : existingRequest.objectId} block:^(id object, NSError *error) {
            
            if (!error) {
                
                /* This is all handled in cloud code now. */
                /******************************************/
                
                //                //Create a relation object. Remember to insert the name of your relation key
                //                PFRelation *friendsRelationForRemoving = [[PFUser currentUser] relationForKey:@"friends"];
                //
                //
                //                //Remove the user from the relation
                //                [friendsRelationForRemoving removeObject:selectedUser];
                //
                //                //Save the current user
                //                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //                    /* Show the error. */
                //                    if (error) {
                //                        NSLog(@"%@ %@", error, [error userInfo]);
                //                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                //                        [alert show];
                //                    } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Connection Removed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                /* Great! Now we can refresh the table to clear the connection from the view. */
                [self refreshTable:nil];
                //                    }
                //                }];
                
            } else {
                /* Show the error. */
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
        
        
        
    }
    
    
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


#pragma mark - IBAction methods
- (IBAction)didPressAddButton:(UIBarButtonItem *)sender {
    NSLog(@"%@", [NSString stringWithFormat:@"Quite the button you got there."]);
}

#pragma mark - Helper methods


@end
