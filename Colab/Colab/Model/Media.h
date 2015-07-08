//
//  Media.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, Location, Metadata, User;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSString * filter;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * mediaId;
@property (nonatomic, retain) Image *image;
@property (nonatomic, retain) Image *thumb;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Metadata *caption;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSNumber * distance;
@end

@interface Media (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Metadata *)value;
- (void)removeTagsObject:(Metadata *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
