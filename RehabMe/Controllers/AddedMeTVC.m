//
//  AddedMeTVC.m
//  RehabMe
//
//  Created by Dan Volz on 7/7/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "AddedMeTVC.h"


@interface AddedMeTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation AddedMeTVC {
    
}

@synthesize selectedIndexPath;

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"FriendRequest";
        
        // The key of the PFObject to display in the label of the default cell style
        //        self.textKey = @"from";
        
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
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query whereKey:@"to" equalTo:[PFUser currentUser]];
    [query whereKey:@"status" equalTo:@"pending"];
    
    return query;
}


#pragma mark - TableView Delegate

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"userCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    
    // Create the text label
    //TODO: make sure it fits if device screen isn't wide enough
    PFUser *fromUser = [object objectForKey:@"from"];
    
    [fromUser fetch];
    
    cell.textLabel.text = [fromUser username];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error userInfo][@"error"]);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to delete exercise.", nil) message:NSLocalizedString(@"", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
        [self refreshTable:nil];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    /* Used in the UIAlertView */
    self.selectedIndexPath = indexPath;
    
    NSLog(@"Selected User: %@", cell.textLabel.text);
    NSString *messageTitle = [NSString stringWithFormat:@"%@ wants to be your friend.", cell.textLabel.text];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:@"Accept Friend Request?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Accept", nil];
    [alert show];
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

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        [self acceptFriendRequestFromUser];
    }
}

#pragma mark - IBAction methods


#pragma mark - Helper methods

- (void)acceptFriendRequestFromUser {
    //get the selected request
    PFObject *friendRequest = [self.objects objectAtIndex:self.selectedIndexPath.row];
    //get the user the request is from
    PFUser *fromUser = [friendRequest objectForKey:@"from"];
    
    //call the cloud function addFriendToFriendRelation which adds the current user to the from users friends:
    //we pass in the object id of the friendRequest as a parameter (you cant pass in objects, so we pass in the id)
    [PFCloud callFunctionInBackground:@"addFriendToFriendsRelation" withParameters:@{@"friendRequest" : friendRequest.objectId} block:^(id object, NSError *error) {
        
        if (!error) {
            //add the fromuser to the currentUsers friends
            PFRelation *friendsRelation = [[PFUser currentUser] relationForKey:@"friends"];
            [friendsRelation addObject:fromUser];
            
            //save the current user
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yay" message:@"Friend request accepted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    /* Great! Now we can refresh the table to clear the request. */
                    [self refreshTable:nil];
                    
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                
            }];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}




@end

