//
//  Location+Interactions.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Location.h"

@class CLLocation;

@interface Location (Interactions)

+ (instancetype)locationWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+ (instancetype)locationWithLocation:(Location *)location inContext:(NSManagedObjectContext *)context;

-(CLLocation *)location;

@end
