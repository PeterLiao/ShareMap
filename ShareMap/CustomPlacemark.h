//
//  CustomPlacemark.h
//  LucyAndMe
//
//  Created by Mac on 2011/6/5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomPlacemark : MKPlacemark {
    int place_id;
    NSString * title;
    NSString * subtitle;
    double latitude;
    double longitude;
    int status;
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int place_id;
@property (nonatomic) int status;

@end
