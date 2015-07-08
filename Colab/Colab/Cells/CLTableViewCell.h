//
//  CLTableViewCell.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface CLTableViewCell : UITableViewCell

- (void)configureCellWithMedia:(Media *)media;

@end
