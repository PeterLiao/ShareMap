//
//  EventMapViewController.m
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "EventMapViewController.h"
#import "CustomPlacemark.h"

@interface EventMapViewController ()

@end

@implementation EventMapViewController

@synthesize placemarkList;
@synthesize responseData = _responseData;
@synthesize mapView = _mapView;
@synthesize searchTextField;

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
	// Do any additional setup after loading the view.
    [_mapView removeAnnotations:[_mapView annotations]];
    placemarkList = [[NSArray alloc] init];

    MapView* mapView = [[MapView alloc] initWithFrame:
						 CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:mapView];
    Place* home = [[Place alloc] init];
	home.name = @"Home";
	home.description = @"Sweet home";
	home.latitude = 25.043119;
	home.longitude = 121.509529;
    
	Place* office = [[Place alloc] init];
	office.name = @"Office";
	office.description = @"Bad office";
	office.latitude = 25.049272;
	office.longitude = 121.516879;
    
    [mapView showRouteFrom:home to:office];
    [self addPlacemark:25.043119 longitude:121.509529 title:@"Jessica" subTitle:@"趕路中(預計5分鐘)" status:STATUS_GOING];
    [self addPlacemark:25.049272 longitude:121.516879 title:@"Miniko" subTitle:@"趕路中(預計10分鐘)" status:STATUS_GOING];

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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addPlacemarkToList:(CustomPlacemark *)placemark
{        
    placemarkList = [placemarkList arrayByAddingObject:placemark];
    [_mapView addAnnotation:placemark];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    self.placemarkList = [[NSArray alloc] init];
    
    // convert to JSON
    //NSError *myError = nil;
    //NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    /*
    for (NSDictionary *result in res) {
        TravelEvent *event = [[TravelEvent alloc] init];
        event.event_id= [[result objectForKey:@"id"] intValue];
        event.name = [result objectForKey:@"name"];
        event.description = [result objectForKey:@"description"];
        event.destination_id = [[result objectForKey:@"destination_id"] intValue];
        event.owner_id = [[result objectForKey:@"owner_id"] intValue];
        self.rowList = [self.rowList arrayByAddingObject:event];
    }
    [_mapView addAnnotations:placemarkList];*/
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0)
{
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知選項" message:@"" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:@"傳送導航", @"迷路求救", @"丟訊息", nil];
    [alert show];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSString *title = annotation.title;
    MKPinAnnotationView *pinView=(MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:title];
    if(pinView==nil)
        pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:title];
    
    CustomPlacemark * placemark = (CustomPlacemark *)annotation;
    if(placemark.status == STATUS_ARRIVED)
        [pinView setPinColor:MKPinAnnotationColorGreen];
    else if(placemark.status == STATUS_MISSING || placemark.status == STATUS_GOING)
        [pinView setPinColor:MKPinAnnotationColorRed];
    else
        [pinView setPinColor:MKPinAnnotationColorPurple];
    
    pinView.canShowCallout=YES;
    pinView.animatesDrop=YES;
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return pinView;
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

- (IBAction)doSearch:(id)sender
{
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:searchTextField.text completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if(placemarks.count > 0)
        {
            NSLog(@"Found placemarks for %@",searchTextField.text);
            CLPlacemark* placemark =  [placemarks objectAtIndex:0];
            double latitude = placemark.location.coordinate.latitude;
            double longitude = placemark.location.coordinate.longitude;
            [self addPlacemark:latitude longitude:longitude title:searchTextField.text subTitle:@"約會地點" status:STATUS_TARGET];
        }
        else
        {
            NSLog(@"Found no placemarks for %@",searchTextField.text);
        }
    }];
    [searchTextField resignFirstResponder];
}

@end
