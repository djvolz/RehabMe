//
//  ExerciseTableViewController.m
//  RehabMe
//
//  Created by Dan Volz on 4/9/15 (at the Istanbul airport).
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "ExerciseTableViewController.h"


@interface ExerciseTableViewController ()

@end

@implementation ExerciseTableViewController {
    
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"Exercise";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"name";
        
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
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"name"];
    
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"ExerciseCell";
    
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
    nameLabel.text = [object objectForKey:@"name"];

    // Create the enable/disable switch
    UISwitch *newsSwitch = (UISwitch *) [cell viewWithTag:102];
    newsSwitch.tag = indexPath.row; // This only works if you can't insert or delete rows without a call to reloadData
    NSNumber *switchStateNumber = [object objectForKey:@"enabled"];
    BOOL switchState = [switchStateNumber boolValue];
    newsSwitch.on = switchState; // this shouldn't be animated
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error userInfo][@"error"]);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Only exercises you've created may be deleted.", nil) message:NSLocalizedString(@"", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
        [self refreshTable:nil];
    }];
}

- (IBAction)didSwitchExerciseDisplaySwitch:(UISwitch *)sender {
    NSInteger  indexRow = sender.tag;
    
    PFObject *object = [self.objects objectAtIndex:indexRow];
    NSLog(@"Switch for %@", [object objectForKey:@"name"]);


    object[@"enabled"] = [NSNumber numberWithBool:sender.on];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSInteger errCode = [error code];
        if (kPFErrorObjectNotFound == errCode) {
            [self createReferenceObjectForObject:object];
        }
    }];
}

- (PFObject *)copyShallowToCloneFromObject:(PFObject *)object {
    PFObject *referenceObject = [PFObject objectWithClassName:self.parseClassName];

    NSArray *keys = [object allKeys];
    for (NSString *key in keys) {
        [referenceObject setObject:[object objectForKey:key] forKey:key];
    }
    
    [referenceObject setACL:[PFACL ACLWithUser:[PFUser currentUser]]];
    
    return referenceObject;
}

- (void)createReferenceObjectForObject:(PFObject *)object {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query whereKey:@"referencingObject" equalTo:object.objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu objects.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
            
            if(objects.count == 0) {
                PFObject *referenceObject = [self copyShallowToCloneFromObject:object];

                [referenceObject setObject:object.objectId forKey:@"referencingObject"];
                [referenceObject setObject:[PFUser currentUser] forKey:@"createdBy"];
                
                [referenceObject saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    NSLog(@"error: %@", [error localizedDescription]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showExerciseDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ExerciseDetailViewController *destViewController = segue.destinationViewController;
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        Exercise *exercise = [[Exercise alloc] init];
        exercise.name = [object objectForKey:@"name"];
        exercise.imageFile = [object objectForKey:@"imageFile"];
        exercise.instructions = [object objectForKey:@"instructions"];
        exercise.timeRequired = [[object objectForKey:@"timeRequired"] intValue];
        destViewController.exercise = exercise;
        
    }
}


@end
