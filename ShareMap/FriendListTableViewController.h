//
//  FriendListTableViewController.h
//  ShareMap
//
//  Created by Mac on 12/10/27.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListTableViewController : UITableViewController
{
    NSMutableArray *rowList;
}
@property (nonatomic, retain) NSMutableArray *rowList;
- (IBAction)doApply:(id)sender;
@end
