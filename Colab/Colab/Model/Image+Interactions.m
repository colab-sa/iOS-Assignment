//
//  Image+Interactions.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Image+Interactions.h"
#import <MagicalRecord.h>

@implementation Image (Interactions)

+ (instancetype)imageWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    if (!dict) {
        return [Image MR_createEntityInContext:context];
    }
    if (!dict[@"url"] || dict[@"url"] == [NSNull null]) {
        return nil;
    }
    Image *image = [Image MR_createEntityInContext:context];
    image.path = dict[@"url"];
    return image;
}

+ (instancetype)imageWithImage:(Image *)image inContext:(NSManagedObjectContext *)context {
    Image *img = [Image MR_createEntityInContext:context];
    img.data = image.data;
    img.path = image.path;
    return img;
}

@end
