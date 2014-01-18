//
//  ImageUtils.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/16/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "ImageUtils.h"

#import "Archimedes.h"

@interface ImageUtils ()
@end

@implementation ImageUtils
+ (UIImage *)imageWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage inContainer:(CGRect)container
{
    CGRect photoBound = container;
    photoBound.size.height = photoBound.size.height / 2;
    
    CGSize topImageRect = MEDSizeScaleAspectFit(topImage.size, photoBound.size);
    CGSize bottomImageRect = MEDSizeScaleAspectFit(bottomImage.size, photoBound.size);
    int topOffset = (container.size.height - (topImageRect.height + bottomImageRect.height)) / 2;
    
    CGPoint topImagePosition = CGPointMake((container.size.width - topImageRect.width)/2, topOffset);
    CGPoint bottomImagePosition = CGPointMake((container.size.width - bottomImageRect.width)/2, topOffset + topImageRect.height);
    
    UIGraphicsBeginImageContext(container.size);
    [topImage drawInRect:CGRectMake(topImagePosition.x, topImagePosition.y, topImageRect.width, topImageRect.height)];
    [bottomImage drawInRect:CGRectMake(bottomImagePosition.x, bottomImagePosition.y, bottomImageRect.width, bottomImageRect.height)];
    UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return combinedImage;
}

+ (UIImage *)imageWithLeftImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage inContainer:(CGRect)container
{
    CGRect photoBound = container;
    photoBound.size.width = photoBound.size.width / 2;
    
    // Calculate container bound in landscape
    container = CGRectMake(0, 0, container.size.height, container.size.width);
    
    CGSize leftImageRect = MEDSizeScaleAspectFit(leftImage.size, photoBound.size);
    CGSize rightImageRect = MEDSizeScaleAspectFit(rightImage.size, photoBound.size);
    int leftOffset = (container.size.width - (leftImageRect.width + rightImageRect.width)) / 2;
    
    CGPoint leftImagePosition = CGPointMake(leftOffset, (container.size.height - leftImageRect.height)/2);
    CGPoint rightImagePosition = CGPointMake(leftOffset + leftImageRect.width, (container.size.height - rightImageRect.height)/2);
    
    UIGraphicsBeginImageContext(container.size);
    [leftImage drawInRect:CGRectMake(leftImagePosition.x, leftImagePosition.y, leftImageRect.width, leftImageRect.height)];
    [rightImage drawInRect:CGRectMake(rightImagePosition.x, rightImagePosition.y, rightImageRect.width, rightImageRect.height)];
    UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return combinedImage;
}


+ (UIImage *)savedImageWithTitle:(NSString *)title {
    NSString *key = [NSString stringWithFormat:@"savedImageData.%@", title];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData* myEncodedImageData = [defaults objectForKey:key];
    UIImage* image = [UIImage imageWithData:myEncodedImageData];
    return image;
}

+ (void)setSavedImage:(UIImage *)image withTitle:(NSString *)title {
    NSString *key = [NSString stringWithFormat:@"savedImageData.%@", title];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData* imageData = UIImagePNGRepresentation(image);
    [defaults setObject:imageData forKey:key];
    [defaults synchronize];
}

@end
