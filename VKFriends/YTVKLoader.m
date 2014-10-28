//
//  VKLoader.m
//  VKFriends
//
//  Created by Rinat Enikeev on 28/10/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "YTVKLoader.h"
#import "YTVKUser.h"

NSString *const kVkApiFriendsMethod = @"https://api.vk.com/method/friends.get?v=5.25&lang=ru&user_id=%d&order=name&count=%d&offset=%lu&fields=photo_50"; // it is so boring to reimplement vk ios sdk.. so KISS my YAGNI :)
NSString *const YTVKErrorDomain = @"YTVkontakteIOSErrorDomain";

@implementation YTVKLoader

#pragma mark - Singleton
static YTVKLoader *defaultInstance = nil;
+ (YTVKLoader *)defaultLoader
{
    @synchronized(self)
    {
        if (defaultInstance == NULL) {
            defaultInstance = [[self alloc] init];
        }
    }
    return defaultInstance;
}

#pragma mark - Friends
-(void)loadFriendsOfUserId:(int)userId withLimit:(int)limit fromOffset:(NSUInteger)offset completion:(VKLoaderCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kVkApiFriendsMethod, userId, limit, (unsigned long)offset]]];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completion(nil, @0, error);
            });
        } else {
            NSError *jsonError = nil;
            
            NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData: data options:0 error:&jsonError];
            NSArray *jsonArray = [[jsonDictionary objectForKey:@"response"] objectForKey:@"items"];
            NSNumber* count = [[jsonDictionary objectForKey:@"response"] objectForKey:@"count"];
            NSDictionary* vkErrorDict = [jsonDictionary objectForKey:@"error"];
            
            if (vkErrorDict != nil) {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : [vkErrorDict valueForKey:@"error_msg"]};
                NSError *vkError = [[NSError alloc] initWithDomain:YTVKErrorDomain
                                                                      code:[[vkErrorDict valueForKey:@"error_code"] integerValue] userInfo:errorDictionary];

                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    completion(nil, @0, vkError);
                });
            } else if (!jsonArray) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    completion(nil, @0, error);
                });
            } else {
                
                // create YTVKUsers from json and pass to completion block
                NSMutableArray* result = [NSMutableArray arrayWithCapacity:[jsonArray count]];
                for(NSDictionary *item in jsonArray) {
                    YTVKUser* user = [[YTVKUser alloc] initWithId:[item valueForKey:@"id"]];
                    user.firstName = [item valueForKey:@"first_name"];
                    user.lastName = [item valueForKey:@"last_name"];
                    user.thumbnailImageUrl = [NSURL URLWithString:[item valueForKey:@"photo_50"]];
                    [result addObject:user];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    completion(result, count, nil);
                });
            }
        }
        
    });
}

@end
