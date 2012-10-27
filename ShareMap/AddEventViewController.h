//
//  AddEventViewController.h
//  ShareMap
//
//  Created by Mac on 12/10/5.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddLocationMapViewController.h"


@interface AddEventViewController : UITableViewController<NSURLConnectionDelegate, AddLocationDelegate>
{
    UITextField *eventTitleTextField;
    UITextField *eventDetailTextField;
    UILabel *eventDateLabel;
    UILabel *eventLocationLabel;
    int connStatus;
    MKPointAnnotation *location;
}
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) IBOutlet UITextField *eventTitleTextField;
@property (nonatomic, retain) IBOutlet UITextField *eventDetailTextField;
@property (nonatomic, retain) IBOutlet UILabel *eventDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *eventLocationLabel;
@property (assign, readwrite) MKPointAnnotation *location;
@property (nonatomic) int connStatus;

- (IBAction)doCancelView:(id)sender;
- (IBAction)addEvent:(id)sender;

- (IBAction)done:(UITextField *)textField;
- (IBAction)backgroundTap:(id)sender;

- (IBAction)showFriendListView:(id)sender;


@end

