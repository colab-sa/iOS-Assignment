//
//  CLTableViewCell.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "CLTableViewCell.h"
#import "Media+Interactions.h"
#import <UIImageView+AFNetworking.h>
#import "UIImage+Filters.h"
#import "Image+Interactions.h"
#import "User+Interactions.h"

@interface CLTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView_thumb;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_likes;
@property (weak, nonatomic) IBOutlet UILabel *label_distance;

@end

@implementation CLTableViewCell

#pragma mark - View Life Cycle

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Instance Methods 

- (void)configureCellWithMedia:(Media *)media {
    self.imageView_thumb.image = nil;
    NSString *path = media.thumb.path;
    if (media.thumb.data) {
        self.imageView_thumb.image = [UIImage imageWithData:media.thumb.data];
    } else if (path) {
    [self.imageView_thumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.imageView_thumb.image = image.grayedImage;
        media.thumb.data = UIImagePNGRepresentation(self.imageView_thumb.image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    }
    self.label_distance.text = [NSString stringWithFormat:@"%.1fkm", media.distance.floatValue/1000.];
    self.label_likes.text = media.likes.stringValue;
    self.label_name.text = media.user.name;
    
}

@end
