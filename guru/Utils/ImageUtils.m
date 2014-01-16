//
//  ImageUtils.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/16/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "ImageUtils.h"

@interface ImageUtils ()
@end

@implementation ImageUtils
+ (UIImage *)imageWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage
{
    UIGraphicsBeginImageContext(CGSizeMake(topImage.size.width, topImage.size.height + bottomImage.size.height));
    [topImage drawInRect:CGRectMake(0, 0, topImage.size.width, topImage.size.height)];
    [bottomImage drawInRect:CGRectMake(0, topImage.size.width, bottomImage.size.width, bottomImage.size.height)];
    UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return combinedImage;
}

+ (UIImage *)imageWithLeftImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage
{
    UIGraphicsBeginImageContext(CGSizeMake(leftImage.size.width + rightImage.size.width, leftImage.size.height));
    [leftImage drawInRect:CGRectMake(0, 0, leftImage.size.width, leftImage.size.height)];
    [rightImage drawInRect:CGRectMake(leftImage.size.width, 0, rightImage.size.width, leftImage.size.height)];
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
