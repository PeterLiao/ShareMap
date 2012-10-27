//
//  LoginViewController.m
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "LoginViewController.h"
#import "FRCurvedTextView.h"
#import "UIGlossyButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+LayerEffects.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize firstCurvedLayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    for (FRCurvedTextView* curvedView in self.view.subviews) {
        curvedView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        curvedView.alpha = 0.0f;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    FRCurvedTextView* currentView;
    
    for (NSInteger i=0; i<[self.view.subviews count]; i++) {
        currentView = [self.view.subviews objectAtIndex:i];
        
        [UIView animateWithDuration:0.5
                              delay:0.1*i
                            options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             currentView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                             currentView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:1.0
                                                   delay:0.0
                                                 options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  currentView.transform = CGAffineTransformIdentity;
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
        
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *baseColor = [UIColor orangeColor];
    UIColor *lighterColor = [self lighterColorForColor:baseColor];
    UIColor *darkerColor = [self darkerColorForColor:baseColor];
    
    firstCurvedLayer.text = @"人肉導航機！";
    firstCurvedLayer.textFont = @"Baskerville Bold";
    firstCurvedLayer.textRadius = 130.0;
    firstCurvedLayer.textColor = lighterColor;
    firstCurvedLayer.textSize = 40.0f;
    
    secondCurvedLayer.text = @"Developed by Visionaries @ 2012";
    secondCurvedLayer.textRadius = -90.0;
    secondCurvedLayer.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    thirdCurvedLayer.text = @"Renrou Navigation";
    thirdCurvedLayer.textRadius = 100.0;
    thirdCurvedLayer.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    
//    fourthCurvedLayer.text = @"Designed by Richard, Tiffany Liu";
//    fourthCurvedLayer.textFont = @"Cochin Bold Italic";
//    fourthCurvedLayer.textRadius = -80.0;
//    fourthCurvedLayer.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    
    // stand action sheet button
	UIGlossyButton *b;
    
    b = (UIGlossyButton*) [self.view viewWithTag: 1018];
	[b useBlackLabel: YES]; b.tintColor = [UIColor whiteColor];
	[b setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
    [b setGradientType:kUIGlossyButtonGradientTypeLinearSmoothExtreme];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}

- (UIColor *)lighterColorForColor:(UIColor *)c
{
    float r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    float r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}
@end
