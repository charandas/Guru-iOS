//
//  YourselfViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/14/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "YourselfViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GetChute.h"
#import <PhotoPickerPlus/PhotoPickerViewController.h>


@interface YourselfViewController () <PhotoPickerViewControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIPopoverController *popoverController;
@end

@implementation YourselfViewController

@synthesize popoverController;

- (IBAction)initiatePopover:(id)sender
{
    [super initiatePopover:sender];
    
    PhotoPickerViewController *picker = [[PhotoPickerViewController alloc ] initWithTitle:[NSString stringWithFormat:@"Photo of %@", self.title]];
    [picker setDelegate:self];
    [picker setIsMultipleSelectionEnabled:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (![[self popoverController] isPopoverVisible]) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            // [popover setPopoverBackgroundViewClass:[GCPopoverBackgroundView class]];
            [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:YES animated:YES];
            self.popoverController = popover;
        }
        else {
            [[self popoverController] dismissPopoverAnimated:YES];
        }
    }
    else {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(BardoPhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //[info objectForKey:UIImagePickerControllerReferenceURL]
    [self setSavedImage:self.image withTitle:self.title];
    
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(BardoPhotoPickerViewController *)picker
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
