//
//  DetailViewController.h
//  DetailViewSwitch
//
//  Created by Tim Harris on 1/17/14.
//  Copyright (c) 2014 Tim Harris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewButtonHandler.h"

@interface DetailViewController : UIViewController <SplitViewButtonHandler>


@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end
