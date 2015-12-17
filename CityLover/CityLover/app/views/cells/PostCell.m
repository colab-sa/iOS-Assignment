//
//  PostCell.m
//  CityLover
//
//  Created by Rafael Rocha on 7/13/15.
//  Copyright (c) 2015 Rocha, O Desenvolvedor. All rights reserved.
//

#import "PostCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RequestManager.h"

@interface PostCell ()
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (strong, nonatomic) IBOutlet UILabel *creatorLabel;
@end

@implementation PostCell

- (void)setData:(Media *)media {
    self.creatorLabel.text = media.username;
    Image *i = (Image *) media.images.allObjects.firstObject;
    
    if (i.imageData) {
        self.thumbnailView.image = [self applyGrayscaleFilter:[UIImage imageWithData:i.imageData]];
    } else {
        [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:i.url]
                              placeholderImage:nil
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         [[RequestManager sharedManager] saveImage:image onEntity:i];
                                         self.thumbnailView.image = [self applyGrayscaleFilter:image];
                                     }];
    }
}

- (UIImage *)applyGrayscaleFilter:(UIImage *)image {
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, image.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    return [UIImage imageWithCGImage:imageRef];
}

@end
