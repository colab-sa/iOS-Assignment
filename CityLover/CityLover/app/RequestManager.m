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

+ (instancetype)sharedManager {
    static RequestManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
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
                                                       @"link" : @"link",
                                                       @"created_time" : @"createdAt",
                                                       @"likes.count" : @"likesCount",
                                                       @"comments.count" : @"commentsCount",
                                                       @"user.username" : @"username",
                                                       @"caption.text" : @"caption",
                                                       @"location.latitude" : @"latitude",
                                                       @"location.longitude" : @"longitude",
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

        NSLog(@"mapp: %@", operation.HTTPRequestOperation.responseString);
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:0 error:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:response[@"pagination"][@"next_url"] forKey:@"nextUrl"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kInstagramRequestFinished" object:self];
 //         NSLog(@"REMOTE: %@", ((Media*)mappingResult.firstObject).remoteId);
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
     }];
}

- (void)fetchNextPage {
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
                                                       @"link" : @"link",
                                                       @"created_time" : @"createdAt",
                                                       @"likes.count" : @"likesCount",
                                                       @"comments.count" : @"commentsCount",
                                                       @"user.username" : @"username",
                                                       @"caption.text" : @"caption",
                                                       @"location.latitude" : @"latitude",
                                                       @"location.longitude" : @"longitude",
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
    
    NSString *requestPath = [[[NSUserDefaults standardUserDefaults] objectForKey:@"nextUrl"] stringByReplacingOccurrencesOfString:@"https://api.instagram.com" withString:@""];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:requestPath parameters:@{@"client_id" : INSTAGRAM_CLIENT_ID} success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        RKLogInfo(@"Loaded %lu objects", (unsigned long) mappingResult.array.count);

        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:0 error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:response[@"pagination"][@"next_url"] forKey:@"nextUrl"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kInstagramRequestFinished" object:self];
        //         NSLog(@"REMOTE: %@", ((Media*)mappingResult.firstObject).remoteId);
        }
      failure: ^(RKObjectRequestOperation *operation, NSError *error) {
          RKLogError(@"Load failed with error: %@", error);
      }];
}

#pragma mark - Core Data

- (NSArray *)fetchPostInDatabase {
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Media"];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"remoteId" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
}

- (void)saveImage:(UIImage *)image onEntity:(Image *)entity {
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    entity.imageData = UIImageJPEGRepresentation(image, 1.f);
    
    NSError *error = nil;
    if(![context saveToPersistentStore:&error]) {
        NSLog(@"Failed saving image on entity: %@", entity);
    }
}

@end
