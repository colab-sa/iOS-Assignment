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
#import "PostViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "RMPickerViewController.h"
#import <CBZSplashView/CBZSplashView.h>

@interface PostsViewController () <CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) NSMutableArray *postsArray;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;
@property (assign, nonatomic) BOOL fetchingMorePosts;

- (IBAction)orderBy:(id)sender;
@end

@implementation PostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PostCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
    self.title = @"City Lover";
    
    UIImage *icon = [UIImage imageNamed:@"heart2.png"];
    UIColor *color = [UIColor colorWithRed:229.f/255.f green:123.f/255.f blue:163.f/225.f alpha:1.f];
    CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:icon backgroundColor:color];
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:splashView];
    [splashView performSelector:@selector(startAnimation) withObject:nil afterDelay:1.5];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if([self locationAuthorized])
        [self.locationManager startUpdatingLocation];
    else
        [self.locationManager requestWhenInUseAuthorization];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:@"kInstagramRequestFinished"
                                               object:nil];
    
    self.fetchingMorePosts = YES;
}

- (NSMutableArray *)postsArray {
    if (!_postsArray) {
        _postsArray = [[self filterArrayByLocation:[[RequestManager sharedManager] fetchPostInDatabase]] mutableCopy];
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
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"PostDetailSegue" sender:self.postsArray[indexPath.row]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PostViewController *pvc = [segue destinationViewController];
    pvc.media = (Media *)sender;
}

#pragma mark - Location delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([self locationAuthorized]){
        [manager startUpdatingLocation];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opa!" message:@"Precisamos da sua localização para mostrar os melhores posts que a cidade tem pra você 😉" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    self.userLocation = newLocation;
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = (CLPlacemark *)placemarks[0];
        NSLog(@"placemark: %@", placemark.locality);
        [[RequestManager sharedManager] fetchAllPostInCity:[self cleanString:placemark.locality]];
    }];
}

- (BOOL)locationAuthorized {
    return [CLLocationManager locationServicesEnabled] &&
    [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied &&
    ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
     [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways);
}

#pragma mark - 

- (NSString *)cleanString:(NSString *)string {
    NSString *cleanString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSData *data = [cleanString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    cleanString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"city: %@", cleanString);
    
    return cleanString;
}

- (NSArray *)filterArrayByLocation:(NSArray *)array {
    return [array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Media *m, NSDictionary *bindings) {
        if (!(m.longitude && m.latitude)) {
            return NO;
        }
        
        CLLocation *postLocation = [[CLLocation alloc] initWithLatitude:m.latitude.doubleValue longitude:m.longitude.doubleValue];
        CLLocationDistance meters = [self.userLocation distanceFromLocation:postLocation];
        NSLog(@"distance: %f", meters);
        if (meters <= 20000) {
            return YES;
        }
        return NO;
    }]];
}

- (NSArray *)filterArrayByLocationAndProximity:(NSArray *)array {
    NSArray *response = [array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Media *m, NSDictionary *bindings) {
        if (!(m.longitude && m.latitude)) {
            return NO;
        }
        
        CLLocation *postLocation = [[CLLocation alloc] initWithLatitude:m.latitude.doubleValue longitude:m.longitude.doubleValue];
        CLLocationDistance meters = [self.userLocation distanceFromLocation:postLocation];
        NSLog(@"distance: %f", meters);
        if (meters <= 20000) {
            return YES;
        }
        return NO;
    }]];
    
    return [response sortedArrayUsingDescriptors:@[]];
}

- (void)reloadTableView {
    self.postsArray = [[self filterArrayByLocation:[[RequestManager sharedManager] fetchPostInDatabase]] mutableCopy];
    [self.tableView reloadData];
    self.fetchingMorePosts = NO;
}

- (IBAction)orderBy:(id)sender {
    RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController *controller) {
        
        NSUInteger selected = [((RMPickerViewController *)controller).picker selectedRowInComponent:0];
        NSLog(@"selected: %lu", (unsigned long)selected);
        
        [self sortPostsBy:selected];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    //Create cancel action
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController *controller) {
        NSLog(@"Action controller was canceled");
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:RMActionControllerStyleWhite selectAction:selectAction andCancelAction:cancelAction];
    
    pickerController.picker.delegate = self;
    pickerController.picker.dataSource = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)sortPostsBy:(NSUInteger)option {
    NSSortDescriptor *descriptor;
    if (option == 2) {
        self.postsArray = [[self.postsArray sortedArrayUsingComparator:^(Media *a, Media *b) {
            CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:a.latitude.doubleValue longitude:a.longitude.doubleValue];
            CLLocation *bLocation = [[CLLocation alloc] initWithLatitude:b.latitude.doubleValue longitude:b.longitude.doubleValue];
            CLLocationDistance aDistance = [self.userLocation distanceFromLocation:aLocation];
            CLLocationDistance bDistance = [self.userLocation distanceFromLocation:bLocation];
            
            if ( aDistance < bDistance ) {
                return (NSComparisonResult) NSOrderedAscending;
            } else if ( aDistance > bDistance) {
                return (NSComparisonResult) NSOrderedDescending;
            } else {
                return (NSComparisonResult) NSOrderedSame;
            }
        }] mutableCopy];
        return;
    } else if (option == 1) {
        descriptor = [NSSortDescriptor sortDescriptorWithKey:@"likesCount" ascending:NO];
    } else if (option == 0) {
        descriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    }
    self.postsArray = [[self.postsArray sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint scrollOffset = scrollView.contentOffset;
    CGRect scrollBounds = scrollView.bounds;
    CGSize scrollContentSize = scrollView.contentSize;
    UIEdgeInsets scrollContentInset = scrollView.contentInset;
    
    float scrollPosY = scrollOffset.y + scrollBounds.size.height - scrollContentInset.bottom;
    
    if (scrollPosY > scrollContentSize.height * 3/4 && !self.fetchingMorePosts && [[NSUserDefaults standardUserDefaults] objectForKey:@"nextUrl"]) {
        self.fetchingMorePosts = YES;
        [[RequestManager sharedManager] fetchNextPage];
    }
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self pickerData].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self pickerData][row];
}

- (NSArray *)pickerData {
    return @[
             @"Date",
             @"Likes",
             @"Distance"
             ];
}

@end
