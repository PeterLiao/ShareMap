//
//  OptionViewController.h
//  ShareMap
//
//  Created by Roger Liu on 12/10/23.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FRCurvedTextView.h"

@interface OptionViewController : UIViewController {
    FRCurvedTextView *firstCurvedLayer;
    IBOutlet FRCurvedTextView *secondCurvedLayer;
    IBOutlet FRCurvedTextView *thirdCurvedLayer;
    IBOutlet FRCurvedTextView *fourthCurvedLayer;
}

@property (nonatomic, retain) IBOutlet FRCurvedTextView *firstCurvedLayer;

@end
