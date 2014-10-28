//
//  VKUser.m
//  VKFriends
//
//  Created by Rinat Enikeev on 28/10/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "YTVKUser.h"

@implementation YTVKUser

-(id)initWithId:(NSNumber*)identifier {
    self = [super init];
    if (self) {
        self.vkUserId = identifier;
    }
    return self;
}

@end
