//
//  GuruDevaViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/14/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "GuruDevaViewController.h"
#import "ParseImagePickerController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface GuruDevaViewController ()

@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) NSURL* imageURL;

@end

@implementation GuruDevaViewController

@synthesize popoverController;

- (void)awakeFromNib
{
    [super awakeFromNib];
 
    static NSString *kParseImagePickerDidFinishPickingNotification = @"kParseImagePickerDidFinishPickingNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhotoURL:) name:kParseImagePickerDidFinishPickingNotification object:nil];
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

#pragma mark - IBActions
- (IBAction)initiatePopover:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParseImagePickerView"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - ParseImagePickerController methods
- (void)didPickPhotoURL:(NSNotification *)notification
{
    self.imageURL = [notification.userInfo objectForKey:UIImagePickerControllerReferenceURL];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
