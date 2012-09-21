//
//  EventViewController.h
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewController : UITableViewController<NSURLConnectionDelegate>
{
    NSArray *rowList;
}
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSArray *rowList;
@end
