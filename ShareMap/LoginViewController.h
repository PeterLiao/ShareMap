//
//  LoginViewController.h
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRCurvedTextView.h"

@interface LoginViewController : UIViewController{
    FRCurvedTextView *firstCurvedLayer;
    IBOutlet FRCurvedTextView *secondCurvedLayer;
    IBOutlet FRCurvedTextView *thirdCurvedLayer;
    IBOutlet FRCurvedTextView *fourthCurvedLayer;
}

@property (nonatomic, retain) IBOutlet FRCurvedTextView *firstCurvedLayer;
- (UIColor *)lighterColorForColor:(UIColor *)c;
@end