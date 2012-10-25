//
//  AddLocationMapViewController.m
//  ShareMap
//
//  Created by Mac on 12/10/20.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "AddLocationMapViewController.h"

@interface AddLocationMapViewController ()

@end

@implementation AddLocationMapViewController

@synthesize searchBar = _searchBar;
@synthesize placemarkList = _placemarkList;
@synthesize mapView = _mapView;
@synthesize locationManager = _locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 導航精細度
	// Do any additional setup after loading the view.
    if ([CLLocationManager locationServicesEnabled]){
        [_locationManager startUpdatingLocation];
        

    }
    [_mapView removeAnnotations:[_mapView annotations]];
    mapView.showsUserLocation = YES;
    CLLocationCoordinate2D userLoc;
    
    userLoc.latitude = mapView.userLocation.location.coordinate.latitude;
    userLoc.longitude = mapView.userLocation.location.coordinate.longitude;
    mapView.region = MKCoordinateRegionMakeWithDistance(userLoc, 50000, 50000);
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.5;
    lpress.allowableMovement = 10.0;
    [_mapView addGestureRecognizer:lpress];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}

- (IBAction)doSearch:(id)sender
{
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:_searchBar.text completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks.count > 0)
         {
             NSLog(@"Found placemarks for %@",_searchBar.text);
             CLPlacemark* placemark =  [placemarks objectAtIndex:0];
             double latitude = placemark.location.coordinate.latitude;
             double longitude = placemark.location.coordinate.longitude;
             [self addPlacemark:latitude longitude:longitude title:_searchBar.text subTitle:@"約會地點" status:STATUS_TARGET];
         }
         else
         {
             NSLog(@"Found no placemarks for %@",_searchBar.text);
         }
     }];
    [_searchBar resignFirstResponder];
}

-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile status:(int) status
{
    CLLocationCoordinate2D coordinae2D;
    coordinae2D.latitude = latitude;
    coordinae2D.longitude = longitude;
    
    CustomPlacemark * placemark = [[CustomPlacemark alloc] initWithCoordinate:coordinae2D addressDictionary:nil];
    [placemark setTitle:title];
    [placemark setSubtitle:subTtile];
    [placemark setStatus:status];
    
    [self addPlacemarkToList:placemark];
    [self resetMapScope:coordinae2D];
    [_mapView setCenterCoordinate:_mapView.centerCoordinate animated:YES];
    [_mapView selectAnnotation:placemark animated:YES];
}

-(void)addPlacemarkToList:(CustomPlacemark *)placemark
{
    placemarkList = [placemarkList arrayByAddingObject:placemark];
    [_mapView addAnnotation:placemark];
}

-(void)resetMapScope:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateSpan span; // create a range of your view
    span.latitudeDelta = 0.0144927536 * 5/3;  // span dimensions.  I have BASE_RADIUS defined as 0.0144927536 which is equivalent to 1 mile
    span.longitudeDelta = 0.0144927536 * 5/3;  // span dimensions
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]; //Get your location and create a CLLocation
    
    MKCoordinateRegion region; //create a region.  No this is not a pointer
    region.center = location.coordinate;  // set the region center to your current location
    
    region.span = span; // Set the region's span to the new span.
    
    [_mapView setRegion:region animated:YES]; // to set the map to the newly created region
    //[mapView setMapType:MKMapTypeHybrid];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)uiSearchBar
{
    NSLog(@"search:%@", uiSearchBar.text);
    [self doSearch:uiSearchBar];
}

- (IBAction)doApply:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)longPress:(UIGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    
    MKPointAnnotation *pointAnnotation = nil;
    pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = touchMapCoordinate;
    pointAnnotation.title = @"目的地";
//    pointAnnotation.subtitle=@"subtitle";
    
    [_mapView addAnnotation:pointAnnotation];
}


#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    [self addPlacemark:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude title:@"Jessica" subTitle:@"目前位置" status:STATUS_GOING];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    NSLog(@"Error: %@",errorType);
}


@end
