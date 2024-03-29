//
//  ChatViewController.h
//  ShareMap
//
//  Created by Roger Liu on 12/10/7.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceViewController.h"
#import "AsyncUdpSocket.h"
#import "IPAddress.h"
#import "GlobalTab.h"

@class BaseTabBarController;

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,FaceDelegate> {
	NSString                   *_titleString;
	NSMutableString            *_messageString;
	NSString                   *_phraseString;
	NSMutableArray		       *_chatArray;
	
	UITableView                *_chatTableView;
	UITextField                *_messageTextField;
	BOOL                       _isFromNewSMS;
	FaceViewController      *_phraseViewController;
	AsyncUdpSocket             *_udpSocket;
	NSDate                     *_lastTime;
    singletonObj * sobj;
    singletonObj * anotherSingle;
    
    
}
@property (nonatomic, retain) BaseTabBarController *basetempController;

@property (nonatomic, retain) IBOutlet UITableView            *chatTableView;
@property (nonatomic, retain) IBOutlet UITextField            *messageTextField;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;
@property (nonatomic, retain) IBOutlet FaceViewController   *phraseViewController;

@property (nonatomic, retain) NSDate                 *lastTime;
@property (nonatomic, retain) AsyncUdpSocket         *udpSocket;

-(IBAction)sendMessage_Click:(id)sender;
-(IBAction)showPhraseInfo:(id)sender;


-(void)openUDPServer;
-(void)sendMassage:(NSString *)message;
-(void)deleteContentFromTableView;

- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf;

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array;
-(UIView *)assembleMessageAtIndex : (NSString *) message from: (BOOL)fromself;

@end
