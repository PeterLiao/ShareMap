//
//  EventViewController.h
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalTab.h"

enum {
    STATUS_CONN_SUCCESS = 0,
    STATUS_CONN_FAIL
};

@interface EventTableViewController : UITableViewController<NSURLConnectionDelegate,UITableViewDelegate,UINavigationControllerDelegate>
{
    NSArray *rowList;
    int connStatus;
    singletonObj * sobj;
}
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) NSArray *rowList;
@property (nonatomic) int connStatus;

- (void)reloadEvent;
- (IBAction)addEvent:(id)sender;
@end
