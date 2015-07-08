//
//  Location+Interactions.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Location+Interactions.h"
#import <MagicalRecord.h>
#import <CoreLocation/CoreLocation.h>

@implementation Location (Interactions)

+ (instancetype)locationWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    Location *location = [Location MR_createEntityInContext:context];
    if (!dict) {
        return location;
    }
    if (dict[@"latitude"] && dict[@"latitude"] != [NSNull null]) {
        location.latitude = dict[@"latitude"];
    } else {
        return nil;
    }
    if (dict[@"longitude"] && dict[@"longitude"] != [NSNull null]) {
        location.longitude = dict[@"longitude"];
    } else {
        return nil;
    }
    if (dict[@"name"] && dict[@"name"] != [NSNull null]) {
        location.name = dict[@"name"];
    }
    return location;
}

+ (instancetype)locationWithLocation:(Location *)location inContext:(NSManagedObjectContext *)context {
    Location *loc = [Location MR_createEntityInContext:context];
    loc.latitude = location.latitude;
    loc.longitude = location.longitude;
    loc.name = location.name;
    return loc;
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.latitude.floatValue longitude:self.longitude.floatValue];
}

@end
