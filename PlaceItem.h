//
//  PlaceItem.h
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceItem : NSObject
{
    double dLatitude;
    double dLongitude;
    NSString *strMapTitle;
    NSString *strMapSubTitle;
}
@property (nonatomic) double dLatitude;
@property (nonatomic) double dLongitude;
@property (nonatomic, retain) NSString *strMapTitle;
@property (nonatomic, retain) NSString *strMapSubTitle;
@end
