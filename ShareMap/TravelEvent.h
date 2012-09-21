//
//  ModChannel.h
//  iMOD
//
//  Created by Mac on 11/9/3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TravelEvent : NSObject
{
    int event_id;
    NSString *name;
    NSString *description;
    NSDate *event_time;
    int destination_id;
    int owner_id;
}
@property (nonatomic) int event_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSDate *event_time;
@property (nonatomic) int destination_id;
@property (nonatomic) int owner_id;

@end
