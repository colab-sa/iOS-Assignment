//
//  Image.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) Media *imageOwner;
@property (nonatomic, retain) Media *thumbOwner;
@property (nonatomic, retain) NSManagedObject *user;

@end
