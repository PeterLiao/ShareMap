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

@interface EventMapViewController : UIViewController<MKMapViewDelegate, NSURLConnectionDelegate>
{
    NSArray * placemarkList;
    IBOutlet MKMapView * mapView;
}
@property (nonatomic, retain) NSArray * placemarkList;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;

-(void) addPlacemarkToList:(CustomPlacemark *)item;
-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile;
@end
