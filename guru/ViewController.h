//
//  ViewController.h
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 7/28/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerViewController.h"

@interface ViewController : UIViewController <PhotoPickerViewControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIPopoverController   *popoverController;

- (IBAction)pickPhotoSelected:(id)sender;

@end
