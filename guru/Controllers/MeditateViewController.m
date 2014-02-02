//
//  MeditateViewController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/16/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "MeditateViewController.h"
#import "ImageUtils.h"
#import "QuoteUtils.h"

@interface MeditateViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIColor *backgroundColor;

- (void)setImage;
+ (NSArray *)imageKeys;

+ (int)quoteCounterForCount:(NSUInteger)count;

@property (weak, nonatomic) IBOutlet UILabel *quote;

@end

@implementation MeditateViewController

@synthesize imageView = _imageView;

- (void)viewDidLoad {
    //[self.navigationController setNavigationBarHidden:YES];
    //UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //[self setImageForOrientation:orientation];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone; //layout adjustements
    }
    
    self.backgroundColor = [UIColor blackColor];
    
    NSArray *quotes = [QuoteUtils quotes];
    NSUInteger numberOfQuotes = [quotes count];
    
    if (numberOfQuotes) {
        int quoteCounter = [MeditateViewController quoteCounterForCount:numberOfQuotes];
        self.quote.text = quotes[quoteCounter][@"text"];
    }
}

- (void) viewDidLayoutSubviews {
    [self setImage];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self.imageView setBackgroundColor:backgroundColor];
}

+ (int)quoteCounterForCount:(NSUInteger)count {
    static int counter = 0;
    int result = counter;
    
    counter++;
    if (counter == count) {
        counter = 0;
    }
    
    return result;
}

+ (NSArray *)imageKeys {
    static NSArray* inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @[@"Guru", @"Yourself"];
    });
    return inst;

}

- (void)setImage {
    NSArray *keys = [MeditateViewController imageKeys];
    UIImage *firstImage = [ImageUtils savedImageWithTitle:keys[0]];
    UIImage *secondImage = [ImageUtils savedImageWithTitle:keys[1]];
    CGRect bounds = self.view.bounds;
    
    int widthDifference = abs(firstImage.size.width + secondImage.size.width - bounds.size.width);
    int heightDifference = abs(firstImage.size.height + secondImage.size.height - bounds.size.height);
    
    if (widthDifference < heightDifference) {
        _imageView.image = [ImageUtils imageWithLeftImage:firstImage rightImage:secondImage inContainer:bounds];
    } else {
        _imageView.image = [ImageUtils imageWithTopImage:firstImage bottomImage:secondImage inContainer:bounds];
    }
}

@end
