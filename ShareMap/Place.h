//
//  Place.h
//  ShareMap
//
//  Created by Roger Liu on 12/10/7.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject {
    
	NSString* name;
	NSString* description;
	double latitude;
	double longitude;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
