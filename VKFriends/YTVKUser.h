//
//  VKUser.h
//  VKFriends
//
//  Created by Rinat Enikeev on 28/10/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//
//  User of Vkontakte social network.

#import <Foundation/Foundation.h>

@interface YTVKUser : NSObject

@property (nonatomic, strong) NSNumber* vkUserId;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSURL* thumbnailImageUrl; // image_50

-(id)initWithId:(NSNumber*)identifier;

@end
