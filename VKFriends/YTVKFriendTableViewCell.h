//
//  YTVKFriendTableViewCell.h
//  VKFriends
//
//  Created by Rinat Enikeev on 28/10/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//
//   Cell for displaying VK user in friends list.

#import <UIKit/UIKit.h>

@interface YTVKFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@end
