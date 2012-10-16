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

enum {
    STATUS_ARRIVED = 0,
    STATUS_GOING,
    STATUS_MISSING,
    STATUS_TARGET
};

@interface EventMapViewController : UIViewController<MKMapViewDelegate, NSURLConnectionDelegate>
{
    NSArray * placemarkList;
    IBOutlet MKMapView * mapView;
    IBOutlet UITextField *searchTextField;
    CALayer *pulseLayer_;
}
@property (nonatomic, retain) NSArray * placemarkList;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;
@property (nonatomic, retain) UITextField *searchTextField;

-(void)resetMapScope:(CLLocationCoordinate2D)coordinate;
-(void)addPlacemarkToList:(CustomPlacemark *)placemark;
-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile status:(int) status;

- (IBAction)doSearch:(id)sender;
@end
