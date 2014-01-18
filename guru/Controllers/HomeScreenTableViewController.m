//
//  HomeScreenTableViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/6/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "HomeScreenTableViewController.h"
#import "BardoPhotoPickerViewController.h"
#import "QuoteUtils.h"

#include <objc/runtime.h>

#define CELL_YOURSELF 0
#define CELL_GURU 1

@interface HomeScreenTableViewController () <UITableViewDelegate, UISplitViewControllerDelegate>

- (void)rowSelectActionForIndexPath:(NSIndexPath*)indexPath
     WithViewController:(BardoPhotoPickerViewController**)viewController
           ForSplitView:(BOOL)splitView;

@end

@implementation HomeScreenTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.splitViewController setDelegate:self];
    
    self.clearsSelectionOnViewWillAppear = NO;
    //self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad
{
    self.navigationItem.title = NSLocalizedString(@"bardo.home_screen_title", "Title");
    [QuoteUtils quotes];
}

+(NSDictionary*)viewControllerTitles {
    static NSDictionary *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @{
                 @"yourselfCell": @{
                         @"customFeaturesMasked": [NSNumber numberWithBool:NO],
                         @"title": @"Yourself",
                         @"storyboardID": @"BardoPhotoPickerVC"
                         },
                 @"guruCell": @{
                         @"customFeaturesMasked": [NSNumber numberWithBool:YES],
                         @"title": @"Guru",
                         @"storyboardID": @"BardoPhotoPickerVC"
                         },
                 @"meditateCell": @{
                         @"title": @"Meditate",
                         @"storyboardID": @"MeditateVC"
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
            vc.customFeaturesMasked = [cellDetails[@"customFeaturesMasked"] boolValue];
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
    return 3;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.splitViewController)
    {
        UIStoryboard *storyboard = [self storyboard];
        DetailViewController *newController;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *cellKey = cell.reuseIdentifier;
        NSDictionary *cellDetails = [HomeScreenTableViewController viewControllerTitles][cellKey];
        newController = [storyboard instantiateViewControllerWithIdentifier:cellDetails[@"storyboardID"]];
        
        // now set this to the navigation controller
        UINavigationController *navController = [[[self splitViewController ] viewControllers ] lastObject ];
        DetailViewController *oldController = [[navController viewControllers] firstObject];
        
        NSArray *newStack = [NSArray arrayWithObjects:newController, nil ];
        [navController setViewControllers:newStack];
        
        UIBarButtonItem *splitViewButton = [[oldController navigationItem] leftBarButtonItem];
        UIPopoverController *popoverController = [oldController masterPopoverController];
        [newController setSplitViewButton:splitViewButton forPopoverController:popoverController];
        
        if ([newController isKindOfClass:[BardoPhotoPickerViewController class]])
        {
            BardoPhotoPickerViewController* vc = (BardoPhotoPickerViewController*)newController;
            [self rowSelectActionForIndexPath:indexPath WithViewController:&vc ForSplitView:YES];
            
        }
        
        // see if we should be hidden
        if (!UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            // we are in portrait mode so go away
            [popoverController dismissPopoverAnimated:YES];
            
        }
    }
}

#pragma mark - Split View Delegate
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    UINavigationController *navController = [[[self splitViewController ] viewControllers ] lastObject ];
    DetailViewController *vc = [[navController viewControllers] firstObject];
    
    [vc setSplitViewButton:barButtonItem forPopoverController:popoverController];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UINavigationController *navController = [[[self splitViewController ] viewControllers ] lastObject ];
    DetailViewController *vc = [[navController viewControllers] firstObject];
    
    [vc setSplitViewButton:nil forPopoverController:nil];
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
