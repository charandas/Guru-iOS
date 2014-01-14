//
//  GuruViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/9/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "GuruViewController.h"
#import "UIPhotoEditViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface GuruViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (void)moveToImageWithTitle:(NSString *)title;
- (UIImage *)savedImageWithTitle:(NSString *)title;
- (void)setSavedImage:(UIImage *)image withTitle:(NSString *)title;

@end

@implementation GuruViewController

// TODO: use for iPad
@synthesize popoverController;

- (void)awakeFromNib
{
    [super awakeFromNib];
    static NSString *kUIPhotoPickerDidFinishPickingNotification = @"kUIPhotoPickerDidFinishPickingNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kUIPhotoPickerDidFinishPickingNotification object:nil];
    
    static NSString *kParseImagePickerDidFinishPickingNotification = @"kParseImagePickerDidFinishPickingNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhotoURL:) name:kParseImagePickerDidFinishPickingNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title) [self moveToImageWithTitle:self.title];
}

#pragma mark - IBAction methods

- (IBAction)selectPhoto:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParseImagePickerView"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)launchEdit:(id)sender {
    UIPhotoEditViewController *photoEditViewController = [[UIPhotoEditViewController alloc] initWithImage:self.image cropMode:UIPhotoEditViewControllerCropModeCircular];
    [self.navigationController pushViewController:photoEditViewController animated:YES];
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

- (UIImage*)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage*)image
{
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self setSavedImage:image withTitle:self.title];
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

#pragma mark - ParseImagePickerController methods

/*
 * Called by a notification whenever the user picks a photo.
 */
- (void)didPickPhotoURL:(NSNotification *)notification
{
    self.imageURL = [notification.userInfo objectForKey:UIImagePickerControllerReferenceURL];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 * Called whenever the user cancels the picker.
 */
- (void)cancelPicker:(id)sender
{

}



@end
