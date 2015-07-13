//
//  RequestManager.h
//  CityLover
//
//  Created by Rafael Rocha on 7/13/15.
//  Copyright (c) 2015 Rocha, O Desenvolvedor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Image.h"

@interface RequestManager : NSObject

+ (instancetype)sharedManager;
- (void)fetchAllPostInCity:(NSString *)city;
- (NSArray *)fetchPostInDatabase;
- (void)saveImage:(UIImage *)image onEntity:(Image *)entity;
@end
