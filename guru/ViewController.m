//
//  ViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 7/28/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "ViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
//#import "GCPopoverBackgroundView.h"
#import "BFCropInterface.h"

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) BFCropInterface *cropper;

@end

@implementation ViewController

@synthesize popoverController, cropper = _cropper, originalImage = _originalImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.scrollView addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)originalImage
{
    return _originalImage;
}

- (void)setOriginalImage:(UIImage *)originalImage
{
    _originalImage = originalImage;
}

- (BFCropInterface *)cropper
{
    if (!_cropper)
    {
        _cropper = [[BFCropInterface alloc]initWithFrame:self.imageView.bounds andImage:self.image];
    }
    return _cropper;
}

- (void)setCropper:(BFCropInterface *)cropper
{
    _cropper = cropper;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    [self.cropper removeFromSuperview];
    self.cropper = nil;
    
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
    self.cropper.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    self.cropper.borderColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.cropper];
}

#pragma mark - IBActions

- (IBAction)pickPhotoSelected:(id)sender
{
    PhotoPickerViewController *picker = [[PhotoPickerViewController alloc ] initWithTitle:[NSString stringWithFormat:@"Photo of %@", self.title]];
    [picker setDelegate:self];
    [picker setIsMultipleSelectionEnabled:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (![[self popoverController] isPopoverVisible]) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            // [popover setPopoverBackgroundViewClass:[GCPopoverBackgroundView class]];
            [popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    // crop image
    UIImage *croppedImage = [self.cropper getCroppedImage];
    
    // remove crop interface from superview
    [self.cropper removeFromSuperview];
    self.cropper = nil;
    
    // display new cropped image
    self.image = croppedImage;
}

- (IBAction)originalPressed:(id)sender {
    // set main image view to original image and add cropper if not already added
    self.image = nil;
    self.image = self.originalImage;
}

#pragma mark - PhotoPickerViewController Delegate Methods


- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.image = self.originalImage;
    
    //[imageView setContentMode:UIViewContentModeScaleAspectFit];
    
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

@end
