//
//  VKLoader.h
//  VKFriends
//
//  Created by Rinat Enikeev on 28/10/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//
//  Singleton for communicating with vkontakte api
#import <Foundation/Foundation.h>
extern NSString *const YTVKErrorDomain;

typedef void(^VKLoaderCompletionBlock)(NSArray *, NSNumber*, NSError *);

@interface YTVKLoader : NSObject
+ (YTVKLoader *)defaultLoader;
-(void)loadFriendsOfUserId:(int)userId withLimit:(int)limit fromOffset:(NSUInteger)offset completion:(VKLoaderCompletionBlock)completion; // VKUsers in resulting array of completion block, total friends count is number

@end
