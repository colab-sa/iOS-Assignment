//
//  User+Interactions.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "User.h"

@interface User (Interactions)

+ (instancetype)userWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+ (instancetype)userWithUser:(User *)user inContext:(NSManagedObjectContext *)context;

@end
