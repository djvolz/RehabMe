//
//  UITableViewController+StorageManagementViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/22/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "VideoTableViewController.h"

#import "ParallaxHeaderView.h"
#import "StoryCommentCell.h"

@implementation VideoTableViewController
{
    NSArray *tableData;
}

- (void)viewDidLoad {
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
    
    [self reloadData];
}

- (void)reloadData {
    tableData = [self getMovFiles];
    
    [self checkIfWeHaveVideos:tableData];
}


- (IBAction)didPressTrashButton:(UIBarButtonItem *)sender {
    [self showDeleteWarningAlert];
}

- (void) checkIfWeHaveVideos:(NSArray *)videos {
    UIBarButtonItem *trashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                            target:self
                                                            action:@selector(didPressTrashButton:)];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    CGRect frame2 = CGRectMake(0, 0, bounds.size.width, 220);
    UIView *overlayView = [[UIView alloc] initWithFrame:frame];
    overlayView.backgroundColor = [UIColor whiteColor];
    
    // No videos found image
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *logo = [UIImage imageNamed:@"rehabme.png"];
    imageView.frame = frame2;
    imageView.image = [logo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.center = self.view.center;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [imageView setTintColor:[UIColor colorWithHexString:REHABME_GREEN]];
    
    // No videos found text
    UILabel *noVideosText = [[UILabel alloc] initWithFrame:frame2];
    noVideosText.text = @"No Videos";
    noVideosText.numberOfLines = 0;
    noVideosText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:35];
    noVideosText.textAlignment = NSTextAlignmentCenter;
    noVideosText.textColor = [UIColor colorWithHexString:REHABME_GREEN];
    
    if ([videos count] == 0) {
        [self.navigationController.navigationBar.topItem setRightBarButtonItem:nil];
        
        [self.view addSubview:overlayView];
        
        [self.view addSubview:noVideosText];
        
        [self.view addSubview: imageView];
        
        [self.view bringSubviewToFront:imageView];
    }
    else {
        [self.navigationController.navigationBar.topItem setRightBarButtonItem:trashItem];
        
        [overlayView removeFromSuperview];
        
        [noVideosText removeFromSuperview];

        [imageView removeFromSuperview];
    }
}

- (NSArray *)getMovFiles {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString  *filePath = documentsURL.path;
    
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];

    NSArray *files = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    NSArray *movFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mov'"]];
    
    return movFiles;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    cell.imageView.image = [self loadVideoPreview:cell.textLabel.text];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSURL *fileURL = [self grabFileURL:[NSString stringWithFormat:@"%@", cell.textLabel.text]];
        NSString  *filePath = fileURL.path;
        
        [self deleteFileAtFilePath:filePath];
        
        [self reloadData];

        // update the table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // reload the table to show any changes to datasource from above deletion
        [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self playVideo:cell.textLabel.text];
}


- (void)deleteFileAtFilePath:(NSString *)filePath {
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSError* error = nil;
    BOOL result;
    
    result = [fileManager removeItemAtPath:filePath error:&error];
    if (!result && error) {
        NSLog(@"oops: %@", error);
    }
    
}


- (NSURL*)grabFileURL:(NSString *)fileName {
 
    // find Documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    // append a file name to it
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];

    return documentsURL;
}


- (void)clearMovsFromStorage {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString  *filePath = documentsURL.path;
    
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator* directoryEnumberator = [fileManager enumeratorAtPath:filePath];
    NSError* error = nil;
    BOOL result;
    
    NSString* file;
    while (file = [directoryEnumberator nextObject]) {
        if ([[file pathExtension] isEqualToString:@"mov"]) {
            result = [fileManager removeItemAtPath:[filePath stringByAppendingPathComponent:file] error:&error];
            if (!result && error) {
                NSLog(@"oops: %@", error);
            }
        }
    }
    
    [self reloadData];
    
    [self.tableView reloadData];
    
    [self showSuccessfulDeleteAlert];
}

- (void)playVideo:(NSString *)videoURL {
    
    // pick a video from the documents directory
    NSURL *video = [self grabFileURL:videoURL];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:video.path];
    
    
    if (fileExists) {
        // create a movie player view controller
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc]initWithContentURL:video];
        [controller.moviePlayer prepareToPlay];
        [controller.moviePlayer play];
        
        
        // and present it
        [self presentMoviePlayerViewControllerAnimated:controller];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"No file found at path: %@", video.path]);
    }
    
}

- (UIImage*)loadVideoPreview:(NSString *)videoName {

    // pick a video from the documents directory
    NSURL *videoURL = [self grabFileURL:videoName];

    // assets and generator
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    // grab a thumbnail screenshot
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:nil];
    
    // construct the thumbnail image and rotate
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:imgRef scale: 1.0 orientation: UIImageOrientationRight];

    return thumbnail;
}


#pragma mark - Alert View

- (void) showSuccessfulDeleteAlert {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Videos Deleted" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void) showDeleteWarningAlert {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Delete All Files?" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Delete", nil];
    
    [alertView show];
}

// Offer to record video if one hasn't already been created
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    } else {
        [self clearMovsFromStorage];
    }
}

@end
