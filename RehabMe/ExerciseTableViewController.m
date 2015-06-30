//
//  ExerciseTableViewController.m
//  RehabMe
//
//  Created by Dan Volz on 4/9/15 (at the Istanbul airport).
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "ExerciseTableViewController.h"


@interface ExerciseTableViewController ()

/* Local datasource to keep track of object ordering.
 * Trying to update server rapidly leads to non-deterministic
 * results. Performs much better simply updating all of the orders
 * at once, after the re-order has completed.
 */
@property (strong, nonatomic) NSMutableArray *objectsOrder;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

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
    
    /* Add a longpress gesture for re-ordering the table. */
    self.longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:self.longPress];
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
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
    }
    
    [query orderByAscending:@"order"];
    
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
//    nameLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"order"]];

    // Create the enable/disable switch
    UISwitch *newsSwitch = (UISwitch *) [cell viewWithTag:102];
    [newsSwitch addTarget:self action:@selector(checkSwitchChanged:) forControlEvents:UIControlEventValueChanged];
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
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to delete exercise.", nil) message:NSLocalizedString(@"", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
        [self refreshTable:nil];
    }];
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    [self checkIfWeHaveExercises:self.objects];
    
    /* Update the local objects order with the new objects. */
    self.objectsOrder = [(NSArray*)self.objects mutableCopy];
    
    NSLog(@"error: %@", [error localizedDescription]);
}


#pragma mark - IBActions

- (void)checkSwitchChanged:(UISwitch *)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil)
    {
        NSInteger  indexRow = indexPath.row;
    
        PFObject *object = [self.objects objectAtIndex:indexRow];
        NSLog(@"Switch for %@", [object objectForKey:@"name"]);
        
        
        object[@"enabled"] = [NSNumber numberWithBool:sender.on];
        
        /* TODO: Maybe pop up a user alertview if something goes wrong like no network? */
        [object save];
        //    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //        NSInteger errCode = [error code];
        //        if (errCode) {
        //            /* TODO: Maybe pop up a user alertview? */
        //            NSLog(@"Error: %@ %@", error, [error userInfo]);
        //        }
        //    }];
    }
}




- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update local data source.
                [self.objectsOrder exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];

                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            /* Update the remote data source. */
            [self updateServerWithNewDataOrder];
            
            break;
        }
    }
}

#pragma mark - Helper methods

- (void)updateServerWithNewDataOrder {

    /* I know this next section gets a little nested, but it offers the smoothest
     * UI while also ensuring a non-deterministic outcome.
     * If network connection is lost post-move there will be an error with
     * ordering where indexpaths won't be updated.
     *
     * You could say I like to live life on the edge, I guess.
     */
    
    /* Disable the gesture while the server is updating. */
    self.longPress.enabled = NO;


    for (NSUInteger i = 0; i < [self.objectsOrder count]; i++) {
        PFObject *object = [self.objectsOrder objectAtIndex:i];
        object[@"order"] = @(i);
        [object saveEventually:^(BOOL succeeded, NSError *error) {
            NSInteger errCode = [error code];
            if (errCode) {
                /* TODO: Maybe pop up a user alertview? */
                NSLog(@"Error: %@ %@", error, [error userInfo]);
               
                /* Server update failed :(, give back the gesture. */
                self.longPress.enabled = YES;
                
            /* Only refresh the table after the very last object has been updated. */
            } else if (i == [self.objectsOrder count] -1){
                /* Update the PFQueryTableView so the view will be correct when scrolling around. */
                [self refreshTable:nil];
                
                /* Server update succeeded, give back the gesture! */
                self.longPress.enabled = YES;
            }
        }];
    }
}

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}




#pragma mark - Segue


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

#pragma mark - Overlay

- (void) checkIfWeHaveExercises:(NSArray *)exercises {
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    CGRect frame2 = CGRectMake(0, 0, bounds.size.width, 220);

    UIView *overlayView = [[UIView alloc] initWithFrame:frame];
    overlayView.backgroundColor = [UIColor whiteColor];
    overlayView.tag = 17; //you can use any number you like

    
    // No videos found image
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *logo = [UIImage imageNamed:@"rehabme.png"];
    imageView.frame = frame2;
    imageView.image = [logo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.center = self.view.center;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [imageView setTintColor:[UIColor colorWithHexString:REHABME_GREEN]];
    [overlayView addSubview:imageView];
    
    // No videos found text
    UILabel *notAvailableText = [[UILabel alloc] initWithFrame:frame2];
    notAvailableText.text = @"No Exercises";
    notAvailableText.numberOfLines = 1;
    notAvailableText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:35];
    notAvailableText.textAlignment = NSTextAlignmentCenter;
    notAvailableText.textColor = [UIColor colorWithHexString:REHABME_GREEN];
    [overlayView addSubview:notAvailableText];
    
    //TODO: FIXME this really shouldn't be so hardcoded
    CGRect frame3 = CGRectMake(0, notAvailableText.frame.size.height - 140, bounds.size.width, 220);

    UILabel *pullText = [[UILabel alloc] initWithFrame:frame3];
    pullText.text = @"Pull to Refresh";
    pullText.numberOfLines = 1;
    pullText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
    pullText.textAlignment = NSTextAlignmentCenter;
    pullText.textColor = [UIColor colorWithHexString:REHABME_GREEN];
    [overlayView addSubview:pullText];
    [overlayView bringSubviewToFront:imageView];

    
    if ([exercises count] == 0) {
        [self.view addSubview:overlayView];
    } else {
        UIView *viewToRemove = [self.view viewWithTag:17];
        [viewToRemove removeFromSuperview];
    }
}



@end

@interface UINavigationItem(MultipleButtonsAddition)
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray* rightBarButtonItemsCollection;
@end

@implementation UINavigationItem(MultipleButtonsAddition)

- (void) setRightBarButtonItemsCollection:(NSArray *)rightBarButtonItemsCollection {
    self.rightBarButtonItems = [rightBarButtonItemsCollection sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
}

//- (void) setLeftBarButtonItemsCollection:(NSArray *)leftBarButtonItemsCollection {
//    self.leftBarButtonItems = [leftBarButtonItemsCollection sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
//}

- (NSArray*) rightBarButtonItemsCollection {
    return self.rightBarButtonItems;
}

//- (NSArray*) leftBarButtonItemsCollection {
//    return self.leftBarButtonItems;
//}

@end
