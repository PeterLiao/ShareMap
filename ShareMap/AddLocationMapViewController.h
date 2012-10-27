//
//  AddLocationMapViewController.h
//  ShareMap
//
//  Created by Mac on 12/10/20.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomPlacemark.h"
#import "ATMHudDelegate.h"

enum {
    STATUS_ARRIVED = 0,
    STATUS_GOING,
    STATUS_MISSING,
    STATUS_TARGET
};
//建立一個協定
@protocol AddLocationDelegate

//協定中的方法
- (void)passLoc:(MKPointAnnotation *)value;
@end


@class ATMHud;

@interface AddLocationMapViewController : UIViewController<MKMapViewDelegate, UISearchBarDelegate,CLLocationManagerDelegate,ATMHudDelegate>
{
    IBOutlet UISearchBar *searchBar;
    NSArray * placemarkList;
    IBOutlet MKMapView * mapView;
    ATMHud *hud;
    MKPointAnnotation *dest;
    IBOutlet UILabel *destination;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray * placemarkList;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (nonatomic, retain) ATMHud *hud;
@property (nonatomic, readwrite) MKPointAnnotation *dest;
@property (nonatomic, retain) IBOutlet UILabel *destination;
@property (strong, nonatomic) IBOutlet CLGeocoder *geoCoder;

- (IBAction)doSearch:(id)sender;
- (IBAction)doApply:(id)sender;

-(void)addPlacemarkToList:(CustomPlacemark *)placemark;
-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile status:(int) status;

//宣告一個採用Page2Delegate協定的物件
@property (weak) id<AddLocationDelegate> delegate;
@end
