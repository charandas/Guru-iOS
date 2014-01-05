//
//  ViewController.h
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 7/28/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerViewController.h"

@interface ViewController : UIViewController <PhotoPickerViewControllerDelegate, UINavigationControllerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIPopoverController   *popoverController;

- (IBAction)pickPhotoSelected:(id)sender;
- (IBAction)pickMultiplePhotosSelected:(id)sender;
- (IBAction)changePage:(id)sender;

@end
