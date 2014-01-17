//
//  MeditateViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/16/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "MeditateViewController.h"
#import "ImageUtils.h"

#import <Parse/Parse.h>

@interface MeditateViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (void)setImageForOrientation:(UIInterfaceOrientation)orientation;
+ (NSArray *)imageKeys;
+ (NSArray *)quotes;
+ (int)quoteCounterForCount:(int)count;

@property (weak, nonatomic) IBOutlet UILabel *quote;

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
    
    NSArray *quotes = [MeditateViewController quotes];
    int numberOfQuotes = [quotes count];
    
    if (numberOfQuotes) {
        int quoteCounter = [MeditateViewController quoteCounterForCount:numberOfQuotes];
        self.quote.text = quotes[quoteCounter][@"text"];
    }
}

+ (int)quoteCounterForCount:(int)count {
    static int counter = 0;
    int result = counter;
    
    counter++;
    if (counter == count) {
        counter = 0;
    }
    
    return result;
}

+ (NSArray *)quotes {
    static NSArray* inst = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        PFQuery *query = [PFQuery queryWithClassName:@"Quote"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    inst = objects;
                });
            }
            else {
                NSLog(@"WARN: error loading photo metadata from parse");
            }
        }];
    });
    
    return inst;
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
