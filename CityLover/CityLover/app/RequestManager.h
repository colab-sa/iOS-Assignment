//
//  RequestManager.h
//  CityLover
//
//  Created by Rafael Rocha on 7/13/15.
//  Copyright (c) 2015 Rocha, O Desenvolvedor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestManager : NSObject

+ (instancetype)sharedDelegate;
- (void)fetchAllPostInCity:(NSString *)city;
- (NSArray *)fetchPostInDatabase;

@end
