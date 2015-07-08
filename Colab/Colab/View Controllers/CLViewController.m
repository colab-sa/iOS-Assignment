//
//  ViewController.m
//  Colab
//
//  Created by Andre Bohlsen on 7/6/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "CLViewController.h"
#import "CLTableViewCell.h"
#import "CLNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "Media+Interactions.h"
#import <MagicalRecord.h>
#import "Location+Interactions.h"
#import "CLDetailsViewController.h"
#import "User+Interactions.h"

@interface CLViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *myLocation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableSet *resultsSet;
@property (strong, nonatomic) NSArray *displayArray;
@property (weak, nonatomic) IBOutlet UILabel *label_tag;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *nextPath;
@property (strong, nonatomic) NSMutableArray *clickedPostsArray;
@property (strong, nonatomic) NSString *arrayPath;

@end

@implementation CLViewController

#pragma mark - View Life Cicle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNibs];
    [self configureViews];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (NSMutableSet *)resultsSet {
    if (!_resultsSet) {
        _resultsSet = [NSMutableSet new];
    }
    return _resultsSet;
}

- (NSMutableArray *)clickedPostsArray {
    if (!_clickedPostsArray) {
        _clickedPostsArray = [NSMutableArray arrayWithContentsOfFile:self.arrayPath];
        if (!_clickedPostsArray) {
            _clickedPostsArray = [NSMutableArray new];
        }
    }
    return _clickedPostsArray;
}

- (NSString *)arrayPath {
    if (!_arrayPath) {
        _arrayPath = [NSString stringWithFormat:@"%@/Documents/clickedPosts",NSHomeDirectory()];
    }
    return _arrayPath;
}


#pragma mark - Actions

- (IBAction)getUserLocationTapped:(UIButton *)sender {
    [self getUserLocation];
}

- (IBAction)changeSortingOrderTapped:(UISegmentedControl *)sender {
    [self updateDisplayingArray];
}
#pragma mark - Instance Methods

- (void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CLTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CLTableViewCell class])];
    
}

- (void)configureViews {
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithRed:248/255. green:248/255. blue:248/255. alpha:1.];
    self.view.backgroundColor = [UIColor colorWithRed:248/255. green:248/255. blue:248/255. alpha:1.];
}

- (void)getUserLocation {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Aviso" message:@"Autorize o uso do GPS em \"Ajustes\"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)retrieveCityNameForLocation:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count >0) {
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *city = placemark.locality;
            NSMutableString *str = [city mutableCopy];
            CFStringTransform((__bridge CFMutableStringRef)str, NULL, kCFStringTransformStripCombiningMarks, NO);
            city = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
            self.label_tag.text = [NSString stringWithFormat:@"Meu local: %@",city];
            [self fetchMediaForCityName:city];
        }
    }];
}

- (void)fetchMediaForCityName:(NSString *)city {
    [[CLNetworking sharedInstance] fetchInstagramMediaWithTag:city success:^(NSArray *responseArray, NSString *nextUrl) {
        self.nextPath = nextUrl;
        for (NSDictionary *dict in responseArray) {
            Media *media = [Media mediaWithDictionary:dict inContext:[NSManagedObjectContext MR_defaultContext]];
            if (media.location) {
                CLLocationDistance distance = [self.myLocation distanceFromLocation:media.location.location];
                if (distance <= 20000) {
                    media.distance = @(distance);
                    [self.resultsSet addObject:media];
                } else {
                    
                }
            }
        }
        [self updateDisplayingArray];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)updateDisplayingArray {
    NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
    if (selectedIndex == 0) {
        //sort by date
        self.displayArray = [self.resultsSet.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
    } else if (selectedIndex == 1) {
        //sort by likes
        self.displayArray = [self.resultsSet.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"likes" ascending:NO]]];
    } else if (selectedIndex == 2) {
        //sort by distance
        self.displayArray = [self.resultsSet.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
    } else if (selectedIndex == 3) {
        //show offline
        self.displayArray = [Media MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]];
    }
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayArray.count ?: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CLTableViewCell class]) forIndexPath:indexPath];
    [cell configureCellWithMedia:self.displayArray[indexPath.row]];
    return cell;
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowDetailsSegue" sender:self.displayArray[indexPath.row]];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.displayArray.count - 3) {
        
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -20) {
        [[CLNetworking sharedInstance] fetchMoreMedia:self.nextPath success:^(NSArray *responseArray, NSString *nextUrl) {
            self.nextPath = nextUrl;
            for (NSDictionary *dict in responseArray) {
                Media *media = [Media mediaWithDictionary:dict inContext:[NSManagedObjectContext MR_defaultContext]];
                if (media.location) {
                    CLLocationDistance distance = [self.myLocation distanceFromLocation:media.location.location];
                    if (distance <= 20000) {
                        media.distance = @(distance);
                        [self.resultsSet addObject:media];
                    } else {
                        
                    }
                }
            }
            [self updateDisplayingArray];
        } failure:^(NSError *error) {
            
        }];
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
        CLDetailsViewController *detailsVC = segue.destinationViewController;
        Media *media = sender;
        [media persist];
        [self.clickedPostsArray addObject:@{@"postId" : media.mediaId ?: @"", @"user name" : media.user.name}];
        [self.clickedPostsArray writeToFile:self.arrayPath atomically:YES];
        detailsVC.media = media;
    }
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Aviso" message:@"Este aplicativo requer o uso do GPS." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.myLocation = [locations lastObject];
    [manager stopUpdatingLocation];
    [self retrieveCityNameForLocation:self.myLocation];
}

@end
