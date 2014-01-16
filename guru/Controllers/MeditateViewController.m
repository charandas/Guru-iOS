//
//  MeditateViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/16/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "MeditateViewController.h"
#import "ImageUtils.h"

@interface MeditateViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (void)setImageForOrientation:(UIInterfaceOrientation)orientation;
+ (NSArray *)imageKeys;

@end

@implementation MeditateViewController

@synthesize imageView = _imageView;

- (void)viewDidLoad {
    //[self.navigationController setNavigationBarHidden:YES];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self setImageForOrientation:orientation];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone; //layout adjustements
    }
}

+ (NSArray *)imageKeys {
    static NSArray* inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @[@"Guru", @"Yourself"];
    });
    return inst;

}

- (void)setImageForOrientation:(UIInterfaceOrientation)orientation {
    NSArray *keys = [MeditateViewController imageKeys];
    UIImage *firstImage = [ImageUtils savedImageWithTitle:keys[0]];
    UIImage *secondImage = [ImageUtils savedImageWithTitle:keys[1]];
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        _imageView.image = [ImageUtils imageWithLeftImage:firstImage rightImage:secondImage];
    } else if (orientation == UIInterfaceOrientationPortrait ||
               orientation == UIInterfaceOrientationPortraitUpsideDown) {
        _imageView.image = [ImageUtils imageWithTopImage:firstImage bottomImage:secondImage];
    }
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self setImageForOrientation:orientation];
}

@end
