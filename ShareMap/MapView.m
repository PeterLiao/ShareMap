//
//  MapView.m
//  ShareMap
//
//  Created by Roger Liu on 12/10/8.
//  Copyright (c) 2012年 Mac. All rights reserved.
//


#import "MapView.h"

@interface MapView()

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;

@end

@implementation MapView

@synthesize lineColor;
@synthesize mapView = _mapView;

- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
        if(mapView){
            mapView.delegate = nil;
            mapView = nil;
        }
		mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		mapView.showsUserLocation = YES;
		[mapView setDelegate:self];
		[self addSubview:mapView];
		routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
		routeView.userInteractionEnabled = NO;
		[mapView addSubview:routeView];
		
		self.lineColor = [UIColor colorWithWhite:0.2 alpha:0.5];
	}
	return self;
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
        
        // calculate distance between them
        //CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
        
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

    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    
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
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[mapView setRegion:region animated:YES];
}

-(void) showRouteFrom: (Place*) f to:(Place*) t {
	
	if(routes) {
		[mapView removeAnnotations:[mapView annotations]];
	}
	
	PlaceMark* from = [[PlaceMark alloc] initWithPlace:f];
	PlaceMark* to = [[PlaceMark alloc] initWithPlace:t];
	
	[mapView addAnnotation:from];
	[mapView addAnnotation:to];
	
	routes = [self calculateRoutesFrom:from.coordinate to:to.coordinate];
	
	[self updateRouteView];
	[self centerMap];
}

-(void) updateRouteView {
    if (routes.count == 0){
        UIAlertView *av=[[UIAlertView alloc]initWithTitle:@"Message" message:@"沒有可到達的路徑" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
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
		CGPoint point = [mapView convertCoordinate:location.coordinate toPointToView:routeView];
		
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

- (void)dealloc {
//	if(routes) {
//		[routes release];
//	}
//	[mapView release];
//	[routeView release];
//    [super dealloc];
}

@end
