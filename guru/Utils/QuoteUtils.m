//
//  QuoteUtils.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/17/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "QuoteUtils.h"

#import <Parse/Parse.h>

@implementation QuoteUtils

+ (NSArray *)quotes {
    static NSArray* inst = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        PFQuery *query = [PFQuery queryWithClassName:@"Quote"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                inst = objects;
            }
            else {
                NSLog(@"WARN: error loading photo metadata from parse");
            }
        }];
    });
    
    return inst;
}

@end
