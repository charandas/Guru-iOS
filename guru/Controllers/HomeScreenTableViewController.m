//
//  HomeScreenTableViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/6/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "HomeScreenTableViewController.h"
#import "BardoPhotoPickerViewController.h"

#include <objc/runtime.h>

#define CELL_YOURSELF 0
#define CELL_GURU 1

@interface HomeScreenTableViewController () <UITableViewDelegate>

- (void)rowSelectActionForIndexPath:(NSIndexPath*)indexPath
     WithViewController:(BardoPhotoPickerViewController**)viewController
           ForSplitView:(BOOL)splitView;

@end

@implementation HomeScreenTableViewController

- (void)viewDidLoad
{
    self.navigationItem.title = @"Customize";
}

+(NSDictionary*)viewControllerTitles {
    static NSDictionary *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @{
                 @"yourselfCell": @{
                         @"photopicker": [NSNumber numberWithBool:YES],
                         @"title": @"Yourself"
                         },
                 @"guruCell": @{
                         @"photopicker": [NSNumber numberWithBool:NO],
                         @"title": @"Guru"
                         }
                 };
    });
    return inst;
}

- (void)rowSelectActionForIndexPath:(NSIndexPath*)indexPath
     WithViewController:(BardoPhotoPickerViewController**)viewController
           ForSplitView:(BOOL)splitView
{
    BardoPhotoPickerViewController *vc = *viewController;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *cellKey = cell.reuseIdentifier;
    NSDictionary *cellDetails = [HomeScreenTableViewController viewControllerTitles][cellKey];
    if (cellDetails) {
        NSString *cellTitle = cellDetails[@"title"];
        if (!splitView || ![vc.title isEqualToString:cellTitle]) {
            vc.photoPickerPlusMode = [cellDetails[@"photopicker"] boolValue];
            vc.title = cellTitle;
        }
        if (splitView) {
            if (vc.title) [vc moveToImageWithTitle:vc.title];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Only ipad can get the detail
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nvc = (UINavigationController*)detail;
        if ([nvc.topViewController isKindOfClass:[BardoPhotoPickerViewController class]])
        {
            BardoPhotoPickerViewController* vc = (BardoPhotoPickerViewController*)nvc.topViewController;
            [self rowSelectActionForIndexPath:indexPath WithViewController:&vc ForSplitView:YES];
            
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BardoPhotoPickerViewController* vc;
    if ([segue.destinationViewController isKindOfClass:[BardoPhotoPickerViewController class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        vc = (BardoPhotoPickerViewController *)segue.destinationViewController;
        [self rowSelectActionForIndexPath:indexPath WithViewController:&vc ForSplitView:NO];
    }
}

@end
