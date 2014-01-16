//
//  PhotoPickerViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/14/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "BardoPhotoPickerViewController.h"
#import "UIPhotoEditViewController.h"
#import "ParseImagePickerController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GetChute.h"
#import <PhotoPickerPlus/PhotoPickerViewController.h>

@interface BardoPhotoPickerViewController () <UISplitViewControllerDelegate, PhotoPickerViewControllerDelegate, UINavigationControllerDelegate>

- (UIImage *)savedImageWithTitle:(NSString *)title;
- (void)setSavedImage:(UIImage *)image withTitle:(NSString *)title;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL* imageURL;

@end

@implementation BardoPhotoPickerViewController

@synthesize popoverController, customFeaturesMasked;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title) [self moveToImageWithTitle:self.title];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setImageURL:(NSURL *)imageURL
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:imageURL
                     options:0
                    progress:nil
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image && finished)
         {
             dispatch_async(dispatch_get_main_queue(), ^(){
                 self.image = image;
             });
         }
     }];
    
}

- (void)moveToImageWithTitle:(NSString *)title
{
    self.image = [self savedImageWithTitle:title];
    self.title = title;
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
    [self setSavedImage:image withTitle:self.title];
}

#pragma mark - IBActions

- (IBAction)launchEdit:(id)sender {
    UIPhotoEditViewController *photoEditViewController = [[UIPhotoEditViewController alloc] initWithImage:self.image cropMode:UIPhotoEditViewControllerCropModeCircular];
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
            [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:NO animated:YES];
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

#pragma mark - UIPhotoPickerController methods
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
    
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didCancelOnPickPhotoURL:(NSNotification *)notification{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UISplitViewController and UIPhotoPickerController setup

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kUIPhotoPickerDidFinishPickingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhotoURL:) name:kParseImagePickerDidFinishPickingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelOnPickPhotoURL:) name:kParseImagePickerDidCancelPickingNotification object:nil];
}


#pragma mark - UISplitViewController Delegate methods only
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

#pragma PhotoPickerPlus Delegate methods
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
