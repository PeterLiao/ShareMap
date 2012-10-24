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
#import "QuadCurveMenuItem.h"

@protocol QuadCurveMenuDelegate;

enum {
    STATUS_ARRIVED = 0,
    STATUS_GOING,
    STATUS_MISSING,
    STATUS_TARGET
};



@interface EventMapViewController : UIViewController< MKMapViewDelegate, NSURLConnectionDelegate, CLLocationManagerDelegate,QuadCurveMenuItemDelegate>
{
    NSArray * placemarkList;
    IBOutlet MKMapView * mapView;
    IBOutlet UITextField *searchTextField;
    IBOutlet UILabel *distance;
    CAShapeLayer *pulseLayer_;
    UIImageView* routeView;
	NSArray* routes;
    UIColor* lineColor;
    double currentLatitude;
    double currentLongitude;
    CLLocationDirection     currentHeading;
    CLLocationDirection     cityHeading;
    
    
    NSArray *_menusArray;
    int _flag;
    NSTimer *_timer;
    QuadCurveMenuItem *_addButton;
    
    __unsafe_unretained id<QuadCurveMenuDelegate> _delegate;
}

@property (nonatomic, retain) NSArray * placemarkList;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;
@property (nonatomic, retain) UITextField *searchTextField;
@property (nonatomic, retain) UILabel *distance;
@property (nonatomic, retain) CAShapeLayer *pulseLayer_;
@property (nonatomic, retain) UIColor* lineColor;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) CLLocation * startingPoint;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CLLocationDirection currentHeading;

@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, getter = isExpanding)     BOOL expanding;
@property (nonatomic, assign) id<QuadCurveMenuDelegate> delegate;
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray;


-(void)resetMapScope:(CLLocationCoordinate2D)coordinate;
-(void)addPlacemarkToList:(CustomPlacemark *)placemark;
-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile status:(int) status;
-(void) showRouteFrom: (Place*) f to:(Place*) t;
- (double)computeAzimuth:(float)lat1 lon1:(float)lon1 lat2:(float)lat2 lon2:(float)lon2;
- (IBAction)doSearch:(id)sender;
- (void)updateHeadingDisplays:(CLLocationDirection) theHeading;
@end


@protocol QuadCurveMenuDelegate <NSObject>
- (void)quadCurveMenu:(EventMapViewController *)menu didSelectIndex:(NSInteger)idx;
@end

