//
//  Metadata+Interactions.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Metadata+Interactions.h"
#import <MagicalRecord.h>

@implementation Metadata (Interactions)

+ (instancetype)metadataWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    if (!dict) {
        return [Metadata MR_createEntityInContext:context];
    }
    if (!dict[@"id"] || dict[@"id"] == [NSNull null]) {
        return nil;
    }
    Metadata *metadata = [Metadata MR_findFirstByAttribute:@"metaId" withValue:dict[@"id"] inContext:context];
    if (!metadata) {
        metadata = [Metadata MR_createEntityInContext:context];
        metadata.metaId = dict[@"id"];
    }
    if (dict[@"text"] && dict[@"text"] != [NSNull null]) {
        metadata.content = dict[@"text"];
    }
    return metadata;
}

+ (instancetype)metadataWithMetadata:(Metadata *)metadata inContext:(NSManagedObjectContext *)context {
    Metadata *meta = [Metadata MR_createEntityInContext:context];
    meta.metaId = metadata.metaId;
    meta.content = metadata.content;
    return meta;
}

+ (instancetype)tagWithString:(NSString *)string inContext:(NSManagedObjectContext *)context {
    if (!string) {
        return [Metadata MR_createEntityInContext:context];
    }
    Metadata *metadata = [Metadata MR_findFirstByAttribute:@"content" withValue:string inContext:context];
    if (!metadata) {
        metadata = [Metadata MR_createEntityInContext:context];
        metadata.content = string;
    }
    return metadata;
}

@end
