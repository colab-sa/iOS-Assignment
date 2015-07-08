//
//  CLNetworking.m
//  Colab
//
//  Created by Andre Bohlsen on 7/6/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "CLNetworking.h"
#import <AFNetworking.h>

#define kBaseURL [NSURL URLWithString:@"https://api.instagram.com/v1/"]
#define kInstagramClientId @"a05b659e99f647e2a391d163357802c0"

@interface CLNetworking ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation CLNetworking

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    __strong static CLNetworking *_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
        _sharedInstance.manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:kBaseURL];
        _sharedInstance.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedInstance.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    return _sharedInstance;
}


#pragma mark - Instance Methods

- (void)fetchInstagramMediaWithTag:(NSString *)tag success:(void (^)(NSArray *, NSString *))successBlock failure:(void (^)(NSError *))failureBlock {
    [self.manager GET:[NSString stringWithFormat:@"tags/%@/media/recent",tag] parameters:@{@"client_id" : kInstagramClientId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject[@"data"],responseObject[@"pagination"][@"next_url"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];
    
}

- (void)fetchMoreMedia:(NSString *)next_path success:(void (^)(NSArray *, NSString *))successBlock failure:(void (^)(NSError *))failureBlock {
    [self.manager GET:[next_path stringByReplacingOccurrencesOfString:kBaseURL.absoluteString withString:@""] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject[@"data"],responseObject[@"pagination"][@"next_url"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];
}

@end
