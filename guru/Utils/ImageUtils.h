//
//  ImageUtils.h
//  guru
//
//  Created by Karan Batra-Daitch on 1/16/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIImage *)imageWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage inContainer:(CGRect)container;
+ (UIImage *)imageWithLeftImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage inContainer:(CGRect)container;
+ (UIImage *)savedImageWithTitle:(NSString *)title;
+ (void)setSavedImage:(UIImage *)image withTitle:(NSString *)title;

@end
