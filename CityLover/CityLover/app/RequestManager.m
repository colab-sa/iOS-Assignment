//
//  RequestManager.m
//  CityLover
//
//  Created by Rafael Rocha on 7/13/15.
//  Copyright (c) 2015 Rocha, O Desenvolvedor. All rights reserved.
//

#import "RequestManager.h"
#import "AppDelegate.h"

#define INSTAGRAM_CLIENT_ID @"7f59f545ada34c388db4c67b4ae678f7"

@interface RequestManager ()
@property (strong, nonatomic) AppDelegate *appDelegate;
@end

@implementation RequestManager

+ (instancetype)sharedDelegate {
    static RequestManager *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[self alloc] init];
    });
    return sharedDelegate;
}


- (void)fetchAllPostInCity:(NSString *)city {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    RKEntityMapping *mediaMapping = [RKEntityMapping mappingForEntityForName:@"Media"
                                                        inManagedObjectStore:appDelegate.managedObjectStore];
    mediaMapping.identificationAttributes = @[ @"remoteId" ];
    
    RKEntityMapping *imagesMapping = [RKEntityMapping mappingForEntityForName:@"Image"
                                                         inManagedObjectStore:appDelegate.managedObjectStore];
    imagesMapping.identificationAttributes = @[ @"url" ];
    
    [mediaMapping addAttributeMappingsFromDictionary:@{
                                                       @"id" : @"remoteId",
                                                       @"distance" : @"distance",
                                                       @"link" : @"link",
                                                       @"created_time" : @"createdAt",
                                                       @"likes.count" : @"likesCount",
                                                       @"comments.count" : @"commentsCount",
                                                       @"user.username" : @"username",
                                                       @"caption.text" : @"caption",
                                                       @"location" : @"location"
                                                       }];
    
    [imagesMapping addAttributeMappingsFromDictionary:@{
                                                        @"standard_resolution.url" : @"url",
                                                        @"standard_resolution.width" : @"width",
                                                        @"standard_resolution.height" : @"height"
                                                        }];
    
    [mediaMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"images"
                                                                                 toKeyPath:@"images"
                                                                               withMapping:imagesMapping]];
    
    RKResponseDescriptor *mediaResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mediaMapping
                                                                                                 method:RKRequestMethodGET
                                                                                            pathPattern:@"/v1/tags/:tag_name/media/recent"
                                                                                                keyPath:@"data"
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:mediaResponseDescriptor];
    
    NSString *requestPath = [NSString stringWithFormat:@"/v1/tags/%@/media/recent", city];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:requestPath parameters:@{@"client_id" : INSTAGRAM_CLIENT_ID} success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        RKLogInfo(@"Loaded %lu objects", (unsigned long) mappingResult.array.count);
         //articles have been saved in core data by now
         NSLog(@"mapp: %@", operation.HTTPRequestOperation.responseString);
        
 
 //         NSLog(@"REMOTE: %@", ((Media*)mappingResult.firstObject).remoteId);
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
     }];
}

- (NSArray *)fetchPostInDatabase {
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Media"];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"remoteId" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
}

@end
