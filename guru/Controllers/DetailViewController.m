//
//  DetailViewController.m
//  DetailViewSwitch
//
//  Created by Tim Harris on 1/17/14.
//  Copyright (c) 2014 Tim Harris. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController()
@property (nonatomic, weak) IBOutlet UILabel *label;
@end


@implementation DetailViewController

@synthesize splitViewButton = _splitViewButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

#pragma mark - Split View Handler
-(void) turnSplitViewButtonOn: (UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *) popoverController {
    barButtonItem.title = NSLocalizedString(@"bardo.home_screen_title", @"Master");
    _splitViewButton = barButtonItem;
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

-(void)turnSplitViewButtonOff {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    _splitViewButton = nil;
    self.masterPopoverController = nil;
    
}

-(void) setSplitViewButton:(UIBarButtonItem *)splitViewButton forPopoverController:(UIPopoverController *)popoverController {
    if (splitViewButton != _splitViewButton) {
        if (splitViewButton) {
            [self turnSplitViewButtonOn:splitViewButton forPopoverController:popoverController];
        } else {
            [self turnSplitViewButtonOff];
        }
    }
}

@end
