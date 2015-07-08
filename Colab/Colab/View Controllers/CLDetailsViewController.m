//
//  CLDetailsViewController.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "CLDetailsViewController.h"
#import <UIImageView+AFNetworking.h>
#import "CLDetailsTableViewCell.h"
#import "Media+Interactions.h"
#import "Image+Interactions.h"
#import <MagicalRecord.h>
#import "User+Interactions.h"
#import "Location+Interactions.h"
#import "Metadata+Interactions.h"

@interface CLDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *detailsArray;

@end

@implementation CLDetailsViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNibs];
    [self configureViews];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (NSMutableArray *)detailsArray {
    if (!_detailsArray) {
        _detailsArray = [NSMutableArray new];
    }
    return _detailsArray;
}

-(void)setMedia:(Media *)media {
    _media = media;
    if (media.user.username.length > 0) {
    [self.detailsArray addObject:@{@"title" : @"username", @"content" : media.user.username}];
    }
    if (media.user.name.length > 0) {
    [self.detailsArray addObject:@{@"title" : @"nome", @"content" : media.user.name}];
    }
    if (media.caption) {
        [self.detailsArray addObject:@{@"title" : @"legenda", @"content" : media.caption.content}];
    }
    if (media.created_at) {
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"dd/MM/yyyy 'às' HH:mm";
        [self.detailsArray addObject:@{@"title" : @"criado em", @"content" : [df stringFromDate:media.created_at]}];
    }
    if (media.location.name) {
        [self.detailsArray addObject:@{@"title" : @"local", @"content" : media.location.name}];
    }
    if (media.distance) {
        [self.detailsArray addObject:@{@"title" : @"distância", @"content" : [NSString stringWithFormat:@"%.1fkm",media.distance.floatValue]}];
    }
    if (media.likes) {
        [self.detailsArray addObject:@{@"title" : @"likes", @"content" : media.likes.stringValue}];
    }
    if (media.filter.length > 0) {
        [self.detailsArray addObject:@{@"title" : @"filter", @"content" : media.filter}];
    }
    if (media.link.length > 0) {
        [self.detailsArray addObject:@{@"title" : @"link", @"content" : media.link}];
    }
    if (media.tags.count > 0) {
        for (Metadata *tag in media.tags) {
            [self.detailsArray addObject:@{@"title" : @"tag", @"content" : tag.content}];
        }
    }
    
}


#pragma mark - Instance Methods

- (void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CLDetailsTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CLDetailsTableViewCell class])];
    
}

- (void)configureViews {
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor colorWithRed:248/255. green:248/255. blue:248/255. alpha:1.];
    self.view.backgroundColor = [UIColor colorWithRed:248/255. green:248/255. blue:248/255. alpha:1.];
    if (self.media.image.data) {
        self.imageView.image = [UIImage imageWithData:self.media.image.data];
    } else if (self.media.image.path) {
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.media.image.path]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.media.image.data = UIImagePNGRepresentation(image);
        [[NSManagedObjectContext MR_rootSavingContext] MR_saveOnlySelfAndWait];
        self.imageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.detailsArray.count ?: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CLDetailsTableViewCell class]) forIndexPath:indexPath];
    NSDictionary *dict = self.detailsArray[indexPath.row];
    [cell configureCellWithTitle:dict[@"title"] content:dict[@"content"]];
    return cell;
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
