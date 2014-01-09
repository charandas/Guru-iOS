//
//  GuruViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/9/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "GuruViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface GuruViewController () <UIScrollViewAccessibilityDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation GuruViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

- (UIImage*)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage*)image
{
    self.imageView.image = image;
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
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
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


@end
