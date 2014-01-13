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

@interface GuruViewController () <UIScrollViewAccessibilityDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GuruViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)launchEdit:(id)sender {
    UIPhotoEditViewController *photoEditViewController = [[UIPhotoEditViewController alloc] initWithImage:self.image cropMode:UIPhotoEditViewControllerCropModeCircular];
    [self.navigationController pushViewController:photoEditViewController animated:YES];
}

- (UIImage*)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage*)image
{
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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

#pragma mark - UIScrollViewDelegate
/*- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}*/


@end
