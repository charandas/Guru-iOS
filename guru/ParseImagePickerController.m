//
//  ParseImagePickerController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/9/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "ParseImagePickerController.h"
#import "GuruViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>

@interface ParseImagePickerController ()

@property (strong, nonatomic) NSArray* guruMetadata;

@end

@implementation ParseImagePickerController

@synthesize guruMetadata = _guruMetadata;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Get guru metadata from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Guru"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.guruMetadata = objects;
            });
        }
        else {
            NSLog(@"WARN: error loading guru image metadata from parse");
        }
    }];
    
}

- (NSArray*)guruMetadata
{
    return _guruMetadata;
}

- (void) setGuruMetadata:(NSArray *)guruMetadata
{
    _guruMetadata = guruMetadata;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.guruMetadata)
        return 0;
    return self.guruMetadata.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.guruMetadata)
        return 0;
    
    id guru = self.guruMetadata[section];
    if ([guru isKindOfClass:[PFObject class]])
    {
        PFObject* guruObject = (PFObject*)guru;
        id images = guruObject[@"images"];
        if ([images isKindOfClass:[NSArray class]])
        {
            NSLog(@"Photos for %@: %d\n", guruObject[@"name"], ((NSArray*)images).count);
            return ((NSArray*)images).count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuruPhotoCell"];
    PFObject *guru = self.guruMetadata[indexPath.section];
    NSString* urlString = guru[@"images"][indexPath.row][@"url"];
    NSURL* url = [NSURL URLWithString:urlString];
    
    cell.textLabel.text = guru[@"name"];
    cell.detailTextLabel.text = guru[@"description"];

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:url
                options:0
                progress:nil
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image && finished)
         {
             dispatch_async(dispatch_get_main_queue(), ^(){
                 cell.imageView.image = image;
                 [cell setNeedsLayout];
             });
         }
     }];

    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[GuruViewController class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFObject *guru = self.guruMetadata[indexPath.section];
        NSString* urlString = guru[@"images"][indexPath.row][@"url"];

        UITableViewCell *cell = sender;
        GuruViewController *vc = (GuruViewController *)segue.destinationViewController;
        vc.title = cell.textLabel.text;
        vc.imageURL = [NSURL URLWithString:urlString];
    }
}

@end
