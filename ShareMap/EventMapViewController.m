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
@synthesize mapView;

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
    [self.mapView removeAnnotations:[mapView annotations]];
    placemarkList = [[NSArray alloc] init];
    /*
    CLLocationCoordinate2D coordinae2D;
    coordinae2D.latitude = 24.158588;
    coordinae2D.longitude = 120.65583;
    
    CustomPlacemark * placemark = [[CustomPlacemark alloc] initWithCoordinate:coordinae2D addressDictionary:nil];
    [placemark setTitle:@"志明"];
    [placemark setSubtitle:@"趕往路途中"];*/
    
    [self addPlacemark:24.158588 longitude:120.65583 title:@"志明" subTitle:@"正在趕路中"];
    [self zoomMap];
    //[self addPlacemarkToList:placemark];
    
    //[self.mapView addAnnotations:placemarkList];
}

-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile
{
    CLLocationCoordinate2D coordinae2D;
    coordinae2D.latitude = latitude;
    coordinae2D.longitude = longitude;
    
    CustomPlacemark * placemark = [[CustomPlacemark alloc] initWithCoordinate:coordinae2D addressDictionary:nil];
    [placemark setTitle:title];
    [placemark setSubtitle:subTtile];
    
    [self addPlacemarkToList:placemark];
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

-(void)addPlacemarkToList:(CustomPlacemark *)item
{    
    CLLocationCoordinate2D coordinae2D;
    coordinae2D.latitude = item.latitude;
    coordinae2D.longitude = item.longitude;
    
    CustomPlacemark * placemark = [[CustomPlacemark alloc] initWithCoordinate:coordinae2D addressDictionary:nil];
    [placemark setTitle:item.title];
    [placemark setSubtitle:item.subtitle];
    
    placemarkList = [placemarkList arrayByAddingObject:placemark];
    
    //NSLog(@"title:%@", item.title);
    [self.mapView addAnnotation:placemark];
    [self.mapView setCenterCoordinate:placemark.coordinate animated:YES];
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
    NSError *myError = nil;
    NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
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
    [self.mapView addAnnotations:placemarkList];*/
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0)
{
    NSLog(@"didSelectAnnotationView title:%@", [view.annotation title]);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"calloutAccessoryControlTapped title:%@", [view.annotation title]);
    /*
    MemoryDetail *memoryDetail = ((CustomPlacemark*)view.annotation).memoryDetail;
    MemoryViewController *memController = [[MemoryViewController alloc] initWithNibName:@"MemoryView" bundle:nil];
    memController.memDetail = memoryDetail;
    [self.navigationController pushViewController:memController animated:YES];
    [memController release];
     */
}

- (MKAnnotationView *)_mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"viewForAnnotation>>>");
    NSString *title = annotation.title;
    NSLog(@"viewForAnnotation: title:%@", title);
    MKPinAnnotationView *pinView=(MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:title];
    
    if(pinView==nil)
        pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:title];
    
    //if(annotation == aMarker)
        [pinView setPinColor:MKPinAnnotationColorGreen];
    //else if(annotation == bMarker)
    //    [pinView setPinColor:MKPinAnnotationColorRed];
    
    pinView.canShowCallout=YES;
    pinView.animatesDrop=YES;
    NSLog(@"viewForAnnotation<<<");
    
    return pinView;
}

-(void)zoomMap:
{
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]; //Get your location and create a CLLocation
    MKCoordinateRegion region; //create a region.  No this is not a pointer
    region.center = location.coordinate;  // set the region center to your current location
    MKCoordinateSpan span; // create a range of your view
    span.latitudeDelta = 0.0144927536 * 5/3;  // span dimensions.  I have BASE_RADIUS defined as 0.0144927536 which is equivalent to 1 mile
    span.longitudeDelta = 0.0144927536 * 5/3;  // span dimensions
    region.span = span; // Set the region's span to the new span.
    [mapView setRegion:region animated:YES]; // to set the map to the newly created region
    //[mapView setMapType:MKMapTypeHybrid];
}

@end
