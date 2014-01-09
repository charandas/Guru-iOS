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

@property (strong, nonatomic) NSArray* photoMetadata;
- (UIImage *)thumbnailForImage:(UIImage*)image ofSize:(CGSize)size;

@end

@implementation ParseImagePickerController

@synthesize photoMetadata = _photoMetadata;

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
    
    // Get photo metadata from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Guru"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoMetadata = objects;
            });
        }
        else {
            NSLog(@"WARN: error loading photo metadata from parse");
        }
    }];
    
}

- (NSArray*)photoMetadata
{
    return _photoMetadata;
}

- (void) setPhotoMetadata:(NSArray *)photoMetadata
{
    _photoMetadata = photoMetadata;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.photoMetadata)
        return 0;
    return self.photoMetadata.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.photoMetadata)
        return 0;
    
    id photo = self.photoMetadata[section];
    if ([photo isKindOfClass:[PFObject class]])
    {
        PFObject* photoObject = (PFObject*)photo;
        id images = photoObject[@"images"];
        if ([images isKindOfClass:[NSArray class]])
        {
            return ((NSArray*)images).count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuruPhotoCell"];
    PFObject *photo = self.photoMetadata[indexPath.section];
    NSString* urlString = photo[@"images"][indexPath.row][@"url"];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //cell.textLabel.text = photo[@"name"];
    //cell.detailTextLabel.text = photo[@"description"];

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:url
                options:0
                progress:nil
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image && finished)
         {
             dispatch_async(dispatch_get_main_queue(), ^(){
                 UIImage *thumb = [self thumbnailForImage:image ofSize:CGSizeMake(60,60)];
                 cell.imageView.image = thumb;
                 [cell setNeedsLayout];
             });
         }
     }];

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    PFObject *photo = self.photoMetadata[section];
    NSString *string;
    if (photo[@"description"])
        string = [NSString stringWithFormat:@"%@ - %@", photo[@"name"], photo[@"description"]];
    else
        string = [NSString stringWithFormat:@"%@", photo[@"name"]];
    
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[GuruViewController class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFObject *photo = self.photoMetadata[indexPath.section];
        NSString* urlString = photo[@"images"][indexPath.row][@"url"];

        UITableViewCell *cell = sender;
        GuruViewController *vc = (GuruViewController *)segue.destinationViewController;
        vc.title = cell.textLabel.text;
        vc.imageURL = [NSURL URLWithString:urlString];
    }
}

- (UIImage *)thumbnailForImage:(UIImage*)image ofSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    // draw scaled image into thumbnail context
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    // pop the context
    UIGraphicsEndImageContext();
    
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    
    return newThumbnail;
}

@end
