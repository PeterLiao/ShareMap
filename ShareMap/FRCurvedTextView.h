//
//  FRCurvedTextView.h
//  ShareMap
//
//  Created by Roger Liu on 12/10/22.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreText/CoreText.h>

@interface FRCurvedTextView : UIView {
    
    BOOL            setupRequired;
    
    CGFloat         _red;
    CGFloat         _green;
    CGFloat         _blue;
    CGFloat         _alpha;
    CTLineRef       _line;
    
    NSAttributedString* attString;
    NSMutableArray*     widthArray;
    NSMutableArray*     angleArray;
    
    CGFloat             textRadius;
    NSString*           text;
    UIColor*            textColor;
    NSString*           textFont;
    CGFloat             textSize;
    
}

@property (nonatomic, retain) NSString* textFont;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) NSString* text;
@property (nonatomic) CGFloat textRadius;
@property (nonatomic) CGFloat textSize;

@end

