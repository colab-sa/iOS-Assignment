//
//  Metadata+Interactions.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Metadata.h"

@interface Metadata (Interactions)

+ (instancetype)metadataWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+ (instancetype)metadataWithMetadata:(Metadata *)metadata inContext:(NSManagedObjectContext *)context;
+ (instancetype)tagWithString:(NSString *)string inContext:(NSManagedObjectContext *)context;

@end
