//
//  CLNetworking.h
//  Colab
//
//  Created by Andre Bohlsen on 7/6/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLNetworking : NSObject

+ (instancetype)sharedInstance;

- (void)fetchInstagramMediaWithTag:(NSString *)tag success:(void (^)(NSArray *responseArray, NSString *nextUrl))successBlock failure:(void (^)(NSError *error))failureBlock;
- (void)fetchMoreMedia:(NSString *)next_path success:(void (^)(NSArray *responseArray, NSString *nextUrl))successBlock failure:(void (^)(NSError *error))failureBlock;
@end
