//
//  EventViewController.h
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    STATUS_CONN_SUCCESS = 0,
    STATUS_CONN_FAIL
};

@interface EventTableViewController : UITableViewController<NSURLConnectionDelegate>
{
    NSArray *rowList;
    int connStatus;
}
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSArray *rowList;
@property (nonatomic) int connStatus;

- (void)reloadEvent;
- (IBAction)addEvent:(id)sender;
@end
