//
//  ParseImagePickerController.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/9/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "ParseImagePickerController.h"
#import "ParseImagePickerTableViewCell.h"
#import "UIPhotoEditViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>

NSString * const kParseImagePickerDidFinishPickingNotification = @"kParseImagePickerDidFinishPickingNotification";
NSString * const kParseImagePickerDidCancelPickingNotification = @"kParseImagePickerDidCancelPickingNotification";

@interface ParseImagePickerController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray *photoMetadata;
@property (strong, nonatomic) NSMutableArray *filteredPhotoMetadata;

/*
 * Proxy class method to be called whenever the user picks a photo.
 *
 * @param editedImage The image result after edition.
 * @param cropRect The applied rectangle on the cropping. If no edited, the default value is CGRectZero.
 * @param originalImage The original image before edition.
 * @param referenceURL The source url of the original image.
 * @param authorName The name of the author of the photo.
 * @param sourceName The name of the servicer provider where the photo was fetched.
 */
+ (void)didFinishPickingImageURL:(NSURL *)imageURL
                  withAuthorName:(NSString *)authorName
                  withSourceName:(NSString *)sourceName;
+ (void)didCancelPickingImageURL;

@end

@implementation ParseImagePickerController

@synthesize photoMetadata = _photoMetadata, filteredPhotoMetadata = _filteredPhotoMetadata;

- (IBAction)dismissSelf:(id)sender {
    [ParseImagePickerController didCancelPickingImageURL];
}

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
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) { /// iOS 7 or above
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Don't show the scope bar or cancel button until editing begins
    [self.searchDisplayController.searchBar setShowsScopeBar:NO];
    [self.searchDisplayController.searchBar sizeToFit];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Get photo metadata from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Guru"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"                                                                         ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            NSArray *sortedArray = [objects sortedArrayUsingDescriptors:sortDescriptors];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoMetadata = sortedArray;
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
    self.filteredPhotoMetadata = [NSMutableArray arrayWithArray:_photoMetadata];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)filteredPhotoMetadata {
    if (!_filteredPhotoMetadata) {
        _filteredPhotoMetadata = [[NSMutableArray alloc] initWithCapacity:self.photoMetadata.count];
    }
    
    return _filteredPhotoMetadata;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *photoMetadata;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        photoMetadata = self.filteredPhotoMetadata;
    } else {
        photoMetadata = self.photoMetadata;
    }
    
    if (!photoMetadata)
        return 0;
    return photoMetadata.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *photoMetadata;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        photoMetadata = self.filteredPhotoMetadata;
    } else {
        photoMetadata = self.photoMetadata;
    }
    
    if (!photoMetadata)
        return 0;
    
    id photo = photoMetadata[section];
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GuruPhotoCell";
    ParseImagePickerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ParseImagePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *photoMetadata;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        photoMetadata = self.filteredPhotoMetadata;
    } else {
        photoMetadata = self.photoMetadata;
    }
    
    PFObject *photo = photoMetadata[indexPath.section];
    NSString* urlString = photo[@"images"][indexPath.row][@"@1x"][@"url"];

    
    //cell.textLabel.text = photo[@"name"];
    //cell.detailTextLabel.text = photo[@"description"];

    [cell.imageView setImageWithURL:[NSURL URLWithString:urlString]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *photoMetadata;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        photoMetadata = self.filteredPhotoMetadata;
    } else {
        photoMetadata = self.photoMetadata;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    // Create custom view to display section header...
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    PFObject *photo = photoMetadata[section];
    NSString *string;
    if (photo[@"description"])
        string = [NSString stringWithFormat:@"%@ - %@", photo[@"name"], photo[@"description"]];
    else
        string = [NSString stringWithFormat:@"%@", photo[@"name"]];
    
    // Section header is in 0th index...
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *photo;
    
    if (self.searchDisplayController.active) {
        photo = self.filteredPhotoMetadata[indexPath.section];
    }
    else {
        photo = self.photoMetadata[indexPath.section];
    }
    
    NSString* urlString = photo[@"images"][indexPath.row][@"normal"][@"url"];
    
    [ParseImagePickerController didFinishPickingImageURL:[NSURL URLWithString:urlString] withAuthorName:nil withSourceName:nil];

}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredPhotoMetadata removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    self.filteredPhotoMetadata = [NSMutableArray arrayWithArray:[self.photoMetadata filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
        self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
}

+ (void)didFinishPickingImageURL:(NSURL *)imageURL
                   withAuthorName:(NSString *)authorName
                   withSourceName:(NSString *)sourceName {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     @"public.image",UIImagePickerControllerMediaType,
                                     nil];
    
    if (imageURL != nil) [userInfo setObject:imageURL.absoluteString forKey:UIImagePickerControllerReferenceURL];
    if (authorName != nil) [userInfo setObject:authorName forKey:UIPhotoPickerControllerAuthorCredits];
    if (sourceName != nil) [userInfo setObject:sourceName forKey:UIPhotoPickerControllerSourceName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kParseImagePickerDidFinishPickingNotification object:nil userInfo:userInfo];
}

+ (void)didCancelPickingImageURL {
    [[NSNotificationCenter defaultCenter] postNotificationName:kParseImagePickerDidCancelPickingNotification object:nil userInfo:nil];
}


@end
