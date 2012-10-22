//
//  PlaceMark.h
//  ShareMap
//
//  Created by Roger Liu on 12/10/8.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface PlaceMark : NSObject <MKAnnotation> {
    
	CLLocationCoordinate2D coordinate;
	Place* place;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Place* place;

-(id) initWithPlace: (Place*) p;

@end
