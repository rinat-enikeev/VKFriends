//
//  ViewController.m
//  VKFriends
//
//  Created by Rinat Enikeev on 28/10/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "YTFriendsTableViewController.h"
#import "YTVKLoader.h"
#import "YTVKFriendTableViewCell.h"
#import "YTVKUser.h"

static NSString * const VKFriendCellReuseIdentifier = @"VKFriendCellReuseIdentifier";
static CGFloat const kVkFriendCellHeight = 44; // need to calculate moment of loading additional friends

@interface YTFriendsTableViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    int _onScreenCellCount;
    int _friendsLoadBatchSize;
    NSUInteger _lastDownloadedFriendNumber;
}
// IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *vkUserIdTextField;
@property (weak, nonatomic) IBOutlet UIView *footerLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data for tableview
@property (nonatomic, strong) NSMutableArray* friends; // of VKUser

// Specific to currently sleected user id
@property (strong, nonatomic) NSNumber* currentUserId;
@property (strong, nonatomic) NSNumber* totalUsersFriendsCount;
@property (nonatomic) BOOL isLoading;
@end

@implementation YTFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _onScreenCellCount = ceil(_tableView.frame.size.height) / kVkFriendCellHeight + 1;
    _friendsLoadBatchSize = _onScreenCellCount * 2;
}

-(void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    _footerLoadingIndicator.hidden = !isLoading;
    _loadingIndicator.hidden = !isLoading;
}

#pragma mark - IBActions
- (IBAction)loadFriends:(id)sender {
    [_vkUserIdTextField resignFirstResponder];
    [self initialLoadFriendsFor:[[[NSNumberFormatter alloc] init] numberFromString:_vkUserIdTextField.text]];
}

- (IBAction)vkUserIdTextFieldEditingDidChange:(UITextField*)sender {
    if (sender == _vkUserIdTextField) {
        if (sender.text.length > 0) {
            _loadButton.enabled = YES;
        } else {
            _loadButton.enabled = NO;
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_friends count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kVkFriendCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YTVKFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VKFriendCellReuseIdentifier forIndexPath:indexPath];
    YTVKUser* friend = [_friends objectAtIndex:[indexPath row]];
    cell.nameLabel.text = [[friend.firstName stringByAppendingString:@" "] stringByAppendingString:[friend lastName]];
    
    // async load of thumbnail
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[friend thumbnailImageUrl]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.thumbImageView.layer.cornerRadius = cell.thumbImageView.frame.size.width / 2;
            cell.thumbImageView.layer.masksToBounds = YES;
            cell.thumbImageView.layer.borderWidth = 0;
            [cell.thumbImageView setImage: img];
        });
    });
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [_vkUserIdTextField resignFirstResponder];
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    // load additional friends when number of currently loaded friends is enough just for on screen of rows under the bottom of visible cell
    float reload_distance = - (_onScreenCellCount * kVkFriendCellHeight);
    if(y > h + reload_distance && !_isLoading && !([_friends count] >= [_totalUsersFriendsCount integerValue])) {
        self.isLoading = YES;
        [[YTVKLoader defaultLoader] loadFriendsOfUserId:[_currentUserId intValue] withLimit:_friendsLoadBatchSize fromOffset:_lastDownloadedFriendNumber completion:^(NSArray *result, NSNumber* totalCount, NSError *error) {
            if (error) {
                [self notifyWithError:error];
            } else {
                self.friends = [NSMutableArray arrayWithArray:[_friends arrayByAddingObjectsFromArray:result]];
                _lastDownloadedFriendNumber = [_friends count];
                [self.tableView reloadData];
            }
            self.isLoading = NO;
        }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YTVKUser* friend = [_friends objectAtIndex:[indexPath row]];
    [self initialLoadFriendsFor:[friend vkUserId]];
    [_vkUserIdTextField setText:[[friend vkUserId] stringValue]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    // prevent from copying text data
    if (textField==_vkUserIdTextField)
    {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString: @"0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if (textField == _vkUserIdTextField) {
        if (textField.text.length > 0) {
            [_vkUserIdTextField resignFirstResponder];
            [self initialLoadFriendsFor:[[[NSNumberFormatter alloc] init] numberFromString:_vkUserIdTextField.text]];
        }
    }
    return YES;
}

#pragma mark - Private
-(void)initialLoadFriendsFor:(NSNumber*)userId
{
    self.currentUserId = userId;
    
    _lastDownloadedFriendNumber = 0;
    self.totalUsersFriendsCount = @0;
    
    self.friends = [NSMutableArray array];
    [self.tableView reloadData];
    self.isLoading = YES;
    [[YTVKLoader defaultLoader] loadFriendsOfUserId:[_currentUserId intValue] withLimit:_friendsLoadBatchSize fromOffset:0 completion:^(NSArray *result, NSNumber* totalCount, NSError *error) {
        if (error) {
            [self notifyWithError:error];
        } else {
            self.friends = [NSMutableArray arrayWithArray:result];
            _lastDownloadedFriendNumber = [_friends count];
            [self.tableView reloadData];
        }
        self.isLoading = NO;
        self.totalUsersFriendsCount = totalCount;
    }];
    
}

-(void)notifyWithError:(NSError*)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil] show];
}

@end
