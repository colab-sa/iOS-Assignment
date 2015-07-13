//
//  PostsViewController.m
//  CityLover
//
//  Created by Rafael Rocha on 7/13/15.
//  Copyright (c) 2015 Rocha, O Desenvolvedor. All rights reserved.
//

#import "PostsViewController.h"
#import "RequestManager.h"
#import "PostCell.h"

@interface PostsViewController ()
@property (strong, nonatomic) NSMutableArray *postsArray;
@end

@implementation PostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PostCell"];
    
    NSString *cityTest = @"São Paulo";
    cityTest = [cityTest stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSData *data = [cityTest dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *city = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"city: %@", city);
    
    [[RequestManager sharedDelegate] fetchAllPostInCity:city];
}

- (NSMutableArray *)postsArray {
    if (!_postsArray) {
        _postsArray = [[[RequestManager sharedDelegate] fetchPostInDatabase] mutableCopy];
    }
    return _postsArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.postsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = (PostCell *)[tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    [cell setData:self.postsArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.f;
}

@end
