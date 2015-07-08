//
//  Image+Interactions.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Image.h"

@interface Image (Interactions)

+ (instancetype)imageWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+ (instancetype)imageWithImage:(Image *)image inContext:(NSManagedObjectContext *)context;

@end
