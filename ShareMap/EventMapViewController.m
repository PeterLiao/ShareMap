//
//  EventMapViewController.m
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "EventMapViewController.h"
#import "CustomPlacemark.h"
#import "QuartzCore/CAAnimation.h"
#import "QuartzCore/CAMediaTimingFunction.h"
#import "UsefulMacros.h"
#import "QuartzCore/CAShapeLayer.h"

@interface EventMapViewController ()

@end

@implementation EventMapViewController

@synthesize placemarkList;
@synthesize responseData = _responseData;
@synthesize mapView = _mapView;
@synthesize searchTextField;
@synthesize pulseLayer_;
@synthesize lineColor;
@synthesize locationManager = _locationManager;
@synthesize startingPoint = _startingPoint;
@synthesize motionManager = _motionManager;

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
    self.locationManager.distanceFilter = 10.0f; //在生成更新位置前，設備必須移動的米數
    //self.locationManager.headingFilter = 30;//在生成更新的指南針讀數之前設備需要轉過的度數 (Notify heading changes when heading is > 30.)
    [_locationManager startUpdatingLocation];

    
    //_mapView.showsUserLocation = YES;
    routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height)];
    routeView.userInteractionEnabled = NO;
    [_mapView addSubview:routeView];
    
    self.lineColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    
	// Do any additional setup after loading the view.
    //[_mapView removeAnnotations:[_mapView annotations]];
    placemarkList = [[NSArray alloc] init];

    
//    Place* home = [[Place alloc] init];
//
//	home.latitude = 25.043119;
//	home.longitude = 121.509529;
//    
//	Place* office = [[Place alloc] init];
//	office.latitude = 25.049272;
//	office.longitude = 121.516879;
//    
//    [self showRouteFrom:home to:office];
    
    pulseLayer_ = [CAShapeLayer layer];
    [_mapView.layer addSublayer:pulseLayer_];
    
    [self addPlacemark:25.043119 longitude:121.509529 title:@"Jessica" subTitle:@"趕路中(預計5分鐘)" status:STATUS_GOING];
    [self addPlacemark:25.049272 longitude:121.516879 title:@"Miniko" subTitle:@"趕路中(預計10分鐘)" status:STATUS_GOING];

    //偵測方向
    
    self.motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    if (_motionManager.accelerometerAvailable){
        _motionManager.accelerometerUpdateInterval = 5;
        [_motionManager startAccelerometerUpdatesToQueue:queue
                        withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                            if (error) {
                                [_motionManager stopAccelerometerUpdates];
                                NSLog(@"Error: %@",error);
                            } else {
                                NSLog(@"x=%f, y=%f, z=%f",accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
                            }
                        }];
    }
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
    //[self resetMapScope:coordinae2D];
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
    
    if([annotation isKindOfClass:[CustomPlacemark class]])
    {
        CustomPlacemark * placemark = (CustomPlacemark *)annotation;
        
        if(placemark.status == STATUS_ARRIVED)
            [pinView setPinColor:MKPinAnnotationColorGreen];
        else if(placemark.status == STATUS_MISSING || placemark.status == STATUS_GOING)
            [pinView setPinColor:MKPinAnnotationColorRed];
        else
            [pinView setPinColor:MKPinAnnotationColorPurple];
    }
    else
    {
        [pinView setPinColor:MKPinAnnotationColorRed];
    }

    pinView.canShowCallout=YES;
    //pinView.animatesDrop=YES;
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

//- (void)loadView {
//    UIView *myView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    myView.backgroundColor = [UIColor whiteColor];
//    
//    pulseLayer_ = [CALayer layer];
//    [myView.layer addSublayer:pulseLayer_];
//    
//    self.view = myView;
//}



- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 25);
    CGPathAddLineToPoint(path, NULL, 35, 50);
    CGPathAddLineToPoint(path, NULL, 15, 50);
    CGPathAddLineToPoint(path, NULL, 25, 75);
    CGPathAddLineToPoint(path, NULL, -25, 75);
    CGPathAddLineToPoint(path, NULL, -15, 50);
    CGPathAddLineToPoint(path, NULL, -35, 50);
    
    //pulseLayer_.backgroundColor = [UIColorFromRGBA(0xFFE365FF, .75) CGColor];
//    pulseLayer_.bounds = CGRectMake(0., 0., 50., 50.);
//    pulseLayer_.cornerRadius = 12.;
//    pulseLayer_.position=CGPointMake(50.0f,50.0f);
    //pulseLayer_.position = self.view.center;
    
    [pulseLayer_ setBounds:CGRectMake(0, 0, 50, 50)];
    //pulseLayer_.fillColor = [[UIColor purpleColor] CGColor];
    [pulseLayer_ setFillColor:[UIColorFromRGBA(0xFFE365FF, .75) CGColor]];


    [pulseLayer_ setPosition:CGPointMake(185, 10)];
    [pulseLayer_ setPath:path];

    //[[[self view] layer]addSublayer:pulseLayer_];
    [pulseLayer_ setNeedsDisplay];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
    
    [pulseLayer_ addAnimation:pulseAnimation forKey:nil];
}

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
    NSInteger turn=0;
    NSLog(@"len=%d, index=%d",len,index);
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5] ;
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		printf("[%f,", [latitude doubleValue]);
		printf("%f]", [longitude doubleValue]);
        
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] ;
        

        
		[array addObject:loc];
        [array2 addObject:latitude];
        [array3 addObject:longitude];
        
	}
    
	for(int i = 1; i < array2.count; i++){
        // calculate distance between them
        CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:[[array2 objectAtIndex:i-1] floatValue] longitude:[[array3 objectAtIndex:i-1] floatValue]] ;
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:[[array2 objectAtIndex:i] floatValue] longitude:[[array3 objectAtIndex:i] floatValue]] ;
        CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
        //        NSLog(@"i=%@",[array2 objectAtIndex:i]);
        if (meters != 0){
            turn++;
            NSLog(@"meters=%f",meters);
        }
    }
    NSLog(@"total turn=%d",turn);
	return array;
}


-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    //    CLLocationCoordinate2D currentLocation = [self getCurrentLocation];  // Use to get current location
    //Or @"http://maps.google.com/maps?saddr=Current+Location&daddr=%@", it need to localize the Current+Location string.
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@&dirflg=w", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	NSLog(@"api url: %@", apiUrl);
    
    NSError *error = nil;
    NSStringEncoding encoding = 0;
//    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error]; // deprecated.

    NSString *apiResponse = [[NSString alloc ]initWithContentsOfURL:apiUrl encoding:encoding error:&error];
    NSLog(@"error: %@", error);
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
	return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap {
    if (routes.count == 0) return;
	MKCoordinateRegion region;

	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;

	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
        
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
        
        
	}
//	region.center.latitude     = (maxLat + minLat) / 2;
//	region.center.longitude    = (maxLon + minLon) / 2;
//	region.span.latitudeDelta  = maxLat - minLat;
//	region.span.longitudeDelta = maxLon - minLon;
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:minLat longitude:minLon];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:maxLat longitude:maxLon];
    

    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];

    region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta = meters / 111319.5;
    region.span.longitudeDelta = 0.0;

	
	[_mapView setRegion:region animated:YES];
}

-(void) showRouteFrom: (Place*) f to:(Place*) t {
	
	if(routes) {
		[_mapView removeAnnotations:[_mapView annotations]];
	}
	
	//PlaceMark* from = [[PlaceMark alloc] initWithPlace:f];
	//PlaceMark* to = [[PlaceMark alloc] initWithPlace:t];

    
    [self addPlacemark:f.latitude longitude:f.longitude title:f.name subTitle:f.description status:STATUS_GOING];
    [self addPlacemark:t.latitude longitude:t.longitude title:t.name subTitle:t.description status:STATUS_GOING];

    CLLocationCoordinate2D coordinae2D_f;
    coordinae2D_f.latitude = f.latitude;
    coordinae2D_f.longitude = f.longitude;
    
    CLLocationCoordinate2D coordinae2D_t;
    coordinae2D_t.latitude = t.latitude;
    coordinae2D_t.longitude = t.longitude;
    
	routes = [self calculateRoutesFrom:coordinae2D_f to:coordinae2D_t];
	[self updateRouteView];
	[self centerMap];
}

-(void) updateRouteView {
    if (routes.count == 0){
        /*
        UIAlertView *av=[[UIAlertView alloc]initWithTitle:@"Message" message:@"沒有可到達的路徑" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        */
         routeView.image = nil;
        return;
    }
    CGContextRef context = 	CGBitmapContextCreate(nil,
												  routeView.frame.size.width,
												  routeView.frame.size.height,
												  8,
												  4 * routeView.frame.size.width,
												  CGColorSpaceCreateDeviceRGB(),
												  kCGImageAlphaPremultipliedLast);
	
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 3.0);
	
	for(int i = 0; i < routes.count; i++) {
		CLLocation* location = [routes objectAtIndex:i];
		CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:routeView];
		
		if(i == 0) {
			CGContextMoveToPoint(context, point.x, routeView.frame.size.height - point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, routeView.frame.size.height - point.y);
		}
	}
	
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
	
	routeView.image = img;
	CGContextRelease(context);
    
}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self updateRouteView];
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}

#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (_startingPoint == nil)
        self.startingPoint = newLocation;
    currentLatitude = newLocation.coordinate.latitude;
    currentLongitude = newLocation.coordinate.longitude;
    NSLog(@"current Latitude:%f",currentLatitude);
    NSLog(@"current Longitude:%f",currentLongitude);
    //    [_mapView.layer addSublayer:pulseLayer_];
    
    Place* from = [[Place alloc] init];
    from.name = @"Jessica";
    from.description = @"趕路中(預計15分鐘)";
	from.latitude = newLocation.coordinate.latitude;
	from.longitude = newLocation.coordinate.longitude;
    
	Place* to = [[Place alloc] init];
    to.name = @"Miniko";
    to.description = @"目的地";
	to.latitude = 25.049272;
	to.longitude = 121.516879;
    
    [self showRouteFrom:from to:to];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    NSLog(@"Error: %@",errorType);
}
@end
