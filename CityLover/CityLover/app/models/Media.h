//
//  Media.h
//  CityLover
//
//  Created by Rafael Rocha on 7/13/15.
//  Copyright (c) 2015 Rocha, O Desenvolvedor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSSet *images;
@end

@interface Media (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
