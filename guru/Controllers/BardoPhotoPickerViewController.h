//
//  PhotoPickerViewController.h
//  guru
//
//  Created by Karan Batra-Daitch on 1/14/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"

@interface BardoPhotoPickerViewController : DetailViewController

@property (nonatomic) BOOL customFeaturesMasked;

- (IBAction)initiatePopover:(id)sender;
- (UIImage *)image;
- (void)moveToImageWithTitle:(NSString *)title;
- (void)setImageURL:(NSURL *)imageURL;

@end
