//
//  UITableViewController+StorageManagementViewController.m
//  RehabMe
//
//  Created by Danny Volz on 3/22/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "StorageManagementViewController.h"

@implementation StorageManagementViewController
{
    NSArray *tableData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadData];
}

- (void)reloadData {
    tableData = [self getMovFiles];
}


- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender {
    // Dismiss this viewcontroller
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressTrashButton:(UIBarButtonItem *)sender {
    [self showDeleteWarningAlert];
}

// Hide the status bar in the menu vie
- (BOOL)prefersStatusBarHidden {
    return YES;
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
    
    [self reloadData];
    
    [self.tableView reloadData];
    
    [self showSuccessfulDeleteAlert];
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
        [self clearStorage];
    }
}

@end
