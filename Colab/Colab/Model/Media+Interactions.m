//
//  Media+Interactions.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "Media+Interactions.h"
#import <MagicalRecord.h>
#import "Metadata+Interactions.h"
#import "Image+Interactions.h"
#import "User+Interactions.h"
#import "Location+Interactions.h"

@implementation Media (Interactions)

+ (instancetype)mediaWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    if (!dict) {
        return [Media MR_createEntityInContext:context];
    }
    if (!dict[@"location"] || dict[@"location"] == [NSNull null] || !dict[@"id"]) {
        return nil;
    }
    Media *media = [Media MR_findFirstByAttribute:@"mediaId" withValue:dict[@"id"] inContext:context];
    if (!media) {
        media = [Media MR_createEntityInContext:context];
        media.mediaId = dict[@"id"];
    }
    if (dict[@"created_time"] && dict[@"created_time"] != [NSNull null]) {
        media.created_at = [NSDate dateWithTimeIntervalSince1970:[dict[@"created_time"]doubleValue]];
    }
    if (dict[@"caption"] && dict[@"caption"] != [NSNull null]) {
        media.caption = [Metadata metadataWithDictionary:dict[@"caption"] inContext:context];
    }
    if (dict[@"link"] && dict[@"link"] != [NSNull null]) {
        media.link = dict[@"link"];
    }
    if (dict[@"tags"] && dict[@"tags"] != [NSNull null]) {
        for (NSString *string in dict[@"tags"]) {
            Metadata *tag = [Metadata tagWithString:string inContext:context];
            [media addTagsObject:tag];
        }
    }
    if (dict[@"likes"] && dict[@"likes"] != [NSNull null]) {
        media.likes = dict[@"likes"][@"count"];
    }
    if (dict[@"filter"] && dict[@"filter"] != [NSNull null]) {
        media.filter = dict[@"filter"];
    }
    if (dict[@"images"] && dict[@"images"] != [NSNull null]) {
        NSDictionary *images = dict[@"images"];
        if (images[@"thumbnail"] && images[@"thumbnail"] != [NSNull null]) {
            media.thumb = [Image imageWithDictionary:images[@"thumbnail"] inContext:context];
        }
        if (images[@"standard_resolution"] && images[@"standard_resolution"] != [NSNull null]) {
            media.image = [Image imageWithDictionary:images[@"standard_resolution"] inContext:context];
        }
    }
    if (dict[@"user"] && dict[@"user"] !=[NSNull null]) {
        media.user = [User userWithDictionary:dict[@"user"] inContext:context];
    }
    if (dict[@"location"] && dict[@"location"] != [NSNull null]) {
        media.location = [Location locationWithDictionary:dict[@"location"] inContext:context];
    }
    return media;
}

+ (instancetype)mediaWithMedia:(Media *)media inContext:(NSManagedObjectContext *)context {
    Media *newMedia;
    if (media.managedObjectContext == context) {
        return media;
    } else {
        newMedia = [Media MR_findFirstByAttribute:@"mediaId" withValue:media.mediaId inContext:context];
    }
    if (!newMedia) {
        newMedia = [Media MR_createEntityInContext:context];
        newMedia.mediaId = media.mediaId;
    }
    if (media.created_at) {
        newMedia.created_at = media.created_at;
    }
    if (media.caption) {
        newMedia.caption = [Metadata metadataWithMetadata:media.caption inContext:context] ;
    }
    if (media.link) {
        newMedia.link = media.link;
    }
    if (media.tags.count) {
        for (Metadata *metadata in media.tags) {
            Metadata *tag = [Metadata tagWithString:metadata.content inContext:context];
            [newMedia addTagsObject:tag];
        }
    }
    if (media.likes) {
        newMedia.likes = media.likes;
    }
    if (media.filter) {
        newMedia.filter = media.filter;
    }
    
    if (media.thumb) {
        newMedia.thumb = [Image imageWithImage:media.thumb inContext:context];
    }
    if (media.image) {
        newMedia.image = [Image imageWithImage:media.image inContext:context];
    }
    if (media.user) {
        newMedia.user = [User userWithUser:media.user inContext:context];
    }
    if (media.location) {
        newMedia.location = [Location locationWithLocation:media.location inContext:context];
    }
    newMedia.distance = media.distance;
    return newMedia;
}

- (void)persist {
    Media *media = [Media mediaWithMedia:self inContext:[NSManagedObjectContext MR_rootSavingContext]];
    [media.managedObjectContext MR_saveOnlySelfAndWait];
}

@end
