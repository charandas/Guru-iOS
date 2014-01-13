//
//  ParseImagePickerTableViewCell.m
//  guru
//
//  Created by Karan Batra-Daitch on 1/11/14.
//  Copyright (c) 2014 Karan Batra-Daitch. All rights reserved.
//

#import "ParseImagePickerTableViewCell.h"

@implementation ParseImagePickerTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, 44, 44);
    float limgW =  self.imageView.image.size.width;
    if(limgW > 0) {
        self.textLabel.frame = CGRectMake(69,self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(69,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
        //[self.imageView.layer setCornerRadius:8.0f];
        [self.imageView.layer setMasksToBounds:YES];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
