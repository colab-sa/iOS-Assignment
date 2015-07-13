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

@interface PostsViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) NSMutableArray *postsArray;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;
@end

@implementation PostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PostCell"];
    
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
    return 75.f;
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

- (void)reloadTableView {
    self.postsArray = [[self filterArrayByLocation:[[RequestManager sharedManager] fetchPostInDatabase]] mutableCopy];
    [self.tableView reloadData];
}

@end
