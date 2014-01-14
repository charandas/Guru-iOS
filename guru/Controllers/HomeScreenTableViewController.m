//
//  HomeScreenTableViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/6/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "HomeScreenTableViewController.h"
#import "BardoPhotoPickerViewController.h"

#define CELL_YOURSELF 0
#define CELL_GURU 1

@interface HomeScreenTableViewController () <UITableViewDelegate>

@end

@implementation HomeScreenTableViewController

- (void)viewDidLoad
{
    self.navigationItem.title = @"Customize";
}

+ (NSArray*)viewControllerTitles
{
    static NSArray *titles = nil;
    
    if (titles == nil)
    {
        titles = @[@"Yourself", @"Guru"];
    }
    
    return titles;
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
            NSString *title = [HomeScreenTableViewController viewControllerTitles][indexPath.row];
            if (![vc.title isEqualToString:title])[vc moveToImageWithTitle:title];
        }
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BardoPhotoPickerViewController* vc;
    if ([segue.destinationViewController isKindOfClass:[BardoPhotoPickerViewController class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        vc = (BardoPhotoPickerViewController *)segue.destinationViewController;
        NSString *title = [HomeScreenTableViewController viewControllerTitles][indexPath.row];
        vc.title = title;
    }
}

@end
