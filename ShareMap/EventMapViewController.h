//
//  EventMapViewController.h
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomPlacemark.h"
#import "MapView.h"
#import "Place.h"
#import "QuartzCore/CAShapeLayer.h"
#import "CoreLocation/CoreLocation.h"
#import "RegexKitLite/RegexKitLite.h"
#import "PlaceMark.h"
#import <CoreMotion/CoreMotion.h>

enum {
    STATUS_ARRIVED = 0,
    STATUS_GOING,
    STATUS_MISSING,
    STATUS_TARGET
};

@interface EventMapViewController : UIViewController<MKMapViewDelegate, NSURLConnectionDelegate, CLLocationManagerDelegate>
{
    NSArray * placemarkList;
    IBOutlet MKMapView * mapView;
    IBOutlet UITextField *searchTextField;
    CAShapeLayer *pulseLayer_;
    UIImageView* routeView;
	NSArray* routes;
    UIColor* lineColor;
    double currentLatitude;
    double currentLongitude;
}

@property (nonatomic, retain) NSArray * placemarkList;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;
@property (nonatomic, retain) UITextField *searchTextField;
@property (nonatomic, retain) CAShapeLayer *pulseLayer_;
@property (nonatomic, retain) UIColor* lineColor;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) CLLocation * startingPoint;
@property (strong, nonatomic) CMMotionManager *motionManager;

-(void)resetMapScope:(CLLocationCoordinate2D)coordinate;
-(void)addPlacemarkToList:(CustomPlacemark *)placemark;
-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile status:(int) status;
-(void) showRouteFrom: (Place*) f to:(Place*) t;

- (IBAction)doSearch:(id)sender;
@end
