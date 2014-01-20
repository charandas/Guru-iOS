//
//  PhotoPickerViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/14/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "BardoPhotoPickerViewController.h"
#import "DZNPhotoEditViewController.h"
#import "ParseImagePickerController.h"
#import "ImageUtils.h"

#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GetChute.h"
#import <PhotoPickerPlus/PhotoPickerViewController.h>

@interface BardoPhotoPickerViewController () <PhotoPickerViewControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL* imageURL;
- (void)setImage:(UIImage *)image;

@end

@implementation BardoPhotoPickerViewController

@synthesize popoverController, customFeaturesMasked;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title) [self moveToImageWithTitle:self.title];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setImageURL:(NSURL *)imageURL
{
    [self.imageView setImageWithURL:imageURL
                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (image)
         {
             [ImageUtils setSavedImage:image withTitle:self.title];
         }
     }
    usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)UIActivityIndicatorViewStyleGray];
}

- (void)moveToImageWithTitle:(NSString *)title
{
    self.image = [ImageUtils savedImageWithTitle:title];
    self.title = title;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [ImageUtils setSavedImage:image withTitle:self.title];
}

#pragma mark - IBActions

- (IBAction)launchEdit:(id)sender {
    DZNPhotoEditViewController *photoEditViewController = [[DZNPhotoEditViewController alloc] initWithImage:self.image cropMode:DZNPhotoEditViewControllerCropModeCircular];
    [self.navigationController pushViewController:photoEditViewController animated:YES];
}

- (IBAction)initiatePopover:(id)sender
{
    PhotoPickerViewController *picker = [[PhotoPickerViewController alloc ] initWithTitle:[NSString stringWithFormat:@"Photo of %@", self.title] forCustomFeaturesMasked:self.customFeaturesMasked];
    
    [picker setDelegate:self];
    [picker setIsMultipleSelectionEnabled:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (![[self popoverController] isPopoverVisible]) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            // [popover setPopoverBackgroundViewClass:[GCPopoverBackgroundView class]];
            [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

#pragma mark - DZNPhotoPickerController methods
- (void)didPickPhoto:(NSNotification *)notification
{
    UIImage *image = [notification.userInfo objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [notification.userInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    self.image = image;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelPicker:(id)sender
{
    
}
#pragma mark - ParseImagePickerController methods
- (void)didPickPhotoURL:(NSNotification *)notification
{
    self.imageURL = [notification.userInfo objectForKey:UIImagePickerControllerReferenceURL];
    // cleanup not performed by chute picker custom popover code
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didCancelOnPickPhotoURL:(NSNotification *)notification{
    // cleanup not performed by chute picker custom popover code
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - DZNPhotoPickerController setup

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kDZNPhotoPickerDidFinishPickingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhotoURL:) name:kParseImagePickerDidFinishPickingNotification object:nil];
}

#pragma PhotoPickerPlus Delegate methods
- (void)imagePickerController:(BardoPhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //[info objectForKey:UIImagePickerControllerReferenceURL]
    [ImageUtils setSavedImage:self.image withTitle:self.title];
    
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
