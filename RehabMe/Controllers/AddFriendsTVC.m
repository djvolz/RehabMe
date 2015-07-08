//
//  AddFriendsTVC.m
//  RehabMe
//
//  Created by Dan Volz on 7/7/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "AddFriendsTVC.h"


@interface AddFriendsTVC () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation AddFriendsTVC {
    
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
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Setup navigation bar to correct coler and font. */
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:REHABME_GREEN]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"Lato" size:20.0],
                                               NSFontAttributeName,
                                               nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    
    /* Search bar setup. */
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;

    self.searchResults = [NSMutableArray array];
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
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if (indexPath.row == 0) {
            PFUser *user = [PFUser currentUser];
            NSString *userNameMessage = [NSString stringWithFormat:@"Your username is %@", [user username]];
            cell.textLabel.text = userNameMessage;
        }
    } else if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = [user username];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"Selected User: %@", cell.textLabel.text);
    
    [self createFriendsRelationToUserAtIndexPath:indexPath];
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
    
    if (tableView == self.tableView) {
        //if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return self.objects.count;
        
    } else {
        
        return self.searchResults.count;
        
    }
    
}


#pragma mark - IBAction methods
- (IBAction)didPressAddButton:(UIBarButtonItem *)sender {
    NSLog(@"%@", [NSString stringWithFormat:@"Quite the button you got there."]);
}

#pragma mark - Helper methods

- (void)createFriendsRelationToUserAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *selectedUser = [self.searchResults objectAtIndex:indexPath.row];
    
    /* Check if user is friend requesting themself. */
    if ([[selectedUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error: Self Request" message:@"Aren't you already friends with yourself?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    /* Check for any existing requests between the two users. */
    NSString *friendRequestClassName = @"FriendRequest";
    
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
    } else if ([friendRequests count] == 1) {
        PFObject *existingRequest = [friendRequests firstObject];
        
        /* Check if pending request already exists. */
        if ([existingRequest[@"status"] isEqualToString:@"pending"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Requested" message:@"Existing request still pending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        
        /* Check if user is already friends with selectedUser. */
        /* (This assumes that friendRequest objects are never deleted. Alternatively
         *  and more slowly I could search through the list of current friends
         *  a user already has, but this way kills two birds with one stone
         *  when I am already checking for current pending requests. 
         */
        } else if ([existingRequest[@"status"] isEqualToString:@"accepted"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Good News!" message:@"You two are already connected!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
    }
    
    
    /* Great, looks like we can setup the friend request! */
    
    PFACL *groupACL = [PFACL ACL];
    
    //request them
    PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
    friendRequest[@"from"] = [PFUser currentUser];
    [groupACL setReadAccess:YES forUser:[PFUser currentUser]];
    [groupACL setWriteAccess:YES forUser:[PFUser currentUser]];
    
    //selected user is the user at the cell that was selected
    friendRequest[@"to"] = selectedUser;
    [groupACL setReadAccess:YES forUser:selectedUser];
    [groupACL setWriteAccess:YES forUser:selectedUser];
    
    /* Make sure both users have permission to see the friend request. */
    friendRequest.ACL = groupACL;
    
    // set the initial status to pending
    friendRequest[@"status"] = @"pending";
    [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yay" message:@"Friend request sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSLog(@"oops: %@", error);
            // error occurred
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

#pragma mark - UISearchBarDelegate

- (void)filterResults:(NSString *)searchTerm {
    
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // Warning: This will be slow for large datasets.
    /* Perform a case insensitive search. */
    [query whereKey:@"username" matchesRegex:self.searchBar.text modifiers:@"i"];
    
    NSArray *results  = [query findObjects];
    
    
    NSLog(@"Results: %@", results);
    NSLog(@"Results Count: %lu", (unsigned long)results.count);
    
    [self.searchResults addObjectsFromArray:results];
    
    [self loadObjects];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if ([searchString length] == 0) {
        return 0;
    } else {
        [self filterResults:searchString];
        return YES;
    }
}


@end
