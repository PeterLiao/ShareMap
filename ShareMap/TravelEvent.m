//
//  ModChannel.m
//  iMOD
//
//  Created by Mac on 11/9/3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TravelEvent.h"

@implementation TravelEvent
@synthesize event_id;
@synthesize name;
@synthesize description;
@synthesize destination_id;
@synthesize owner_id;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
