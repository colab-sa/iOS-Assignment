//
//  PostViewController.m
//  CityLover
//
//  Created by Rafael Rocha on 7/13/15.
//  Copyright (c) 2015 Rocha, O Desenvolvedor. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *pictureView;
@property (strong, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *captionLabel;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pictureView.image = [UIImage imageWithData: ((Image *) self.media.images.allObjects.firstObject).imageData];
    self.likesCountLabel.text = [NSString stringWithFormat: @"%@", self.media.likesCount];
    self.commentsCountLabel.text = [NSString stringWithFormat: @"%@", self.media.commentsCount];
    self.usernameLabel.text = self.media.username;
    self.captionLabel.text = self.media.caption;
    
    CGRect rect = self.captionLabel.bounds;
    rect.size = CGSizeMake(self.captionLabel.bounds.size.width, [self.media.caption boundingRectWithSize:CGSizeMake(self.captionLabel.bounds.size.width, DBL_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.f]}
                                                                   context:nil].size.height);
    self.captionLabel.frame = rect;
    [self.view layoutSubviews];
}

@end
