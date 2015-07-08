//
//  Metadata.h
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface Metadata : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) Media *tagOwner;
@property (nonatomic, retain) Media *captionOwner;
@property (nonatomic, retain) NSString *metaId;

@end
