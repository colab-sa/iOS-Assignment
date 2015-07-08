//
//  CLDetailsTableViewCell.m
//  Colab
//
//  Created by Andre Bohlsen on 7/8/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "CLDetailsTableViewCell.h"

@interface CLDetailsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *label_type;
@property (weak, nonatomic) IBOutlet UILabel *label_content;


@end

@implementation CLDetailsTableViewCell

- (void)configureCellWithTitle:(NSString *)title content:(NSString *)content {
    self.label_type.text = [NSString stringWithFormat:@"%@:",title];
    self.label_content.text = content;
}

@end
