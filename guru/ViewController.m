//
//  ViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 7/28/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "ViewController.h"
#import "UIPhotoEditViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "GetChute.h"

@interface ViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

- (UIImage *)savedImageWithTitle:(NSString *)title;
- (void)setSavedImage:(UIImage *)image withTitle:(NSString *)title;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

@synthesize popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title) [self moveToImageWithTitle:self.title];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.image) {
        PhotoPickerViewController *picker = [[PhotoPickerViewController alloc ] initWithTitle:[NSString stringWithFormat:@"Photo of %@", self.title]];
        [picker setDelegate:self];
        [picker setIsMultipleSelectionEnabled:NO];
        [self presentViewController:picker animated:animated completion:nil];
    }
}

- (void)moveToImageWithTitle:(NSString *)title
{
    self.image = [self savedImageWithTitle:title];
    self.title = title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)savedImageWithTitle:(NSString *)title {
    NSString *key = [NSString stringWithFormat:@"savedImageData.%@", title];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData* myEncodedImageData = [defaults objectForKey:key];
    UIImage* image = [UIImage imageWithData:myEncodedImageData];
    return image;
}

- (void)setSavedImage:(UIImage *)image withTitle:(NSString *)title {
    NSString *key = [NSString stringWithFormat:@"savedImageData.%@", title];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData* imageData = UIImagePNGRepresentation(image);
    [defaults setObject:imageData forKey:key];
    [defaults synchronize];
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - IBActions

- (IBAction)launchEdit:(id)sender {
    UIPhotoEditViewController *photoEditViewController = [[UIPhotoEditViewController alloc] initWithImage:self.image cropMode:UIPhotoEditViewControllerCropModeCircular];
    [self.navigationController pushViewController:photoEditViewController animated:YES];
}

- (IBAction)pickPhotoSelected:(id)sender
{
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

- (IBAction)cropPressed:(id)sender {
}

- (IBAction)originalPressed:(id)sender {
}

#pragma mark - PhotoPickerViewControllerDelegate
- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
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

- (void)imagePickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

# pragma mark - UISplitViewControllerDelegate
- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
    
    static NSString *kUIPhotoPickerDidFinishPickingNotification = @"kUIPhotoPickerDidFinishPickingNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kUIPhotoPickerDidFinishPickingNotification object:nil];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - UIPhotoPickerController methods

/*
 * Called by a notification whenever the user picks a photo.
 */
- (void)didPickPhoto:(NSNotification *)notification
{
    UIImage *image = [notification.userInfo objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [notification.userInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    self.image = image;
    [self setSavedImage:image withTitle:self.title];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 * Called whenever the user cancels the picker.
 */
- (void)cancelPicker:(id)sender
{
    
}

@end
