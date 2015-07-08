//
//  Media+Interactions.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Media.h"

@interface Media (Interactions)

+ (instancetype)mediaWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

- (void)persist;

@end
