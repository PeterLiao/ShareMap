//
//  MapView.h
//  ShareMap
//
//  Created by Roger Liu on 12/10/8.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite/RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"

@interface MapView : UIView<MKMapViewDelegate> {
    
	MKMapView* mapView;
	UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;
}

@property (nonatomic, retain) UIColor* lineColor;
@property (nonatomic, retain) MKMapView * mapView;

-(void) showRouteFrom: (Place*) f to:(Place*) t;


@end
