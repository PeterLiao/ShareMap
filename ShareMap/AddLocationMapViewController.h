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

enum {
    STATUS_ARRIVED = 0,
    STATUS_GOING,
    STATUS_MISSING,
    STATUS_TARGET
};

@interface AddLocationMapViewController : UIViewController<MKMapViewDelegate, UISearchBarDelegate>
{
    IBOutlet UISearchBar *searchBar;
    NSArray * placemarkList;
    IBOutlet MKMapView * mapView;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray * placemarkList;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;

- (IBAction)doSearch:(id)sender;
- (IBAction)doApply:(id)sender;

-(void)addPlacemarkToList:(CustomPlacemark *)placemark;
-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile status:(int) status;

@end
