//
//  User+Interactions.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "User+Interactions.h"
#import <MagicalRecord.h>
#import "Image+Interactions.h"

@implementation User (Interactions)

+ (instancetype)userWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    if (!dict) {
        return [User MR_createEntityInContext:context];
    }
    if (!dict[@"id"] || dict[@"id"] == [NSNull null]) {
        return nil;
    }
    User *user = [User MR_findFirstByAttribute:@"userId" withValue:dict[@"id"] inContext:context];
    if (!user) {
        user = [User MR_createEntityInContext:context];
        user.userId = dict[@"id"];
    }
    if (dict[@"full_name"] && dict[@"full_name"] != [NSNull null]) {
        user.name = dict[@"full_name"];
    }
    if (dict[@"username"] && dict[@"username"] != [NSNull null]) {
        user.username = dict[@"username"];
    }
    if (dict[@"profile_picture"] && dict[@"profile_picture"] != [NSNull null]) {
        user.avatar = [Image imageWithDictionary:nil inContext:context];
        user.avatar.path = dict[@"profile_picture"];
    }
    return user;
}

+ (instancetype)userWithUser:(User *)user inContext:(NSManagedObjectContext *)context {
    User *usr = [User MR_findFirstByAttribute:@"userId" withValue:user.userId inContext:context];
    if (!usr) {
        usr = [User MR_createEntityInContext:context];
        usr.userId = user.userId;
    }
        usr.name = user.name;
        usr.username = user.username;
        usr.avatar = [Image imageWithImage:user.avatar inContext:context];
    return usr;
}

@end
