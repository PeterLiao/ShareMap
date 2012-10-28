//
//  OptionViewController.m
//  ShareMap
//
//  Created by Roger Liu on 12/10/23.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "OptionViewController.h"
#import "FRCurvedTextView.h"

#define ALMOST_PI (M_PI-0.001)

@implementation OptionViewController
@synthesize firstCurvedLayer;

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
    sobj = [singletonObj singleObj];  // 宣告全域物件
    self.tabBarController.title = sobj.eventTitle;
    
    firstCurvedLayer.text = @"人肉導航機";
    firstCurvedLayer.textFont = @"Baskerville Bold";
    firstCurvedLayer.textRadius = 130.0;
    firstCurvedLayer.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    firstCurvedLayer.textSize = 40.0f;
    
    secondCurvedLayer.text = @"Written by: Roger Liu, Peter Liou";
    secondCurvedLayer.textRadius = -110.0;
    secondCurvedLayer.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    thirdCurvedLayer.text = @"Renrou Navigation";
    thirdCurvedLayer.textRadius = 100.0;
    thirdCurvedLayer.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    fourthCurvedLayer.text = @"Designed by Richard, Tiffany Liu";
    fourthCurvedLayer.textFont = @"Cochin Bold Italic";
    fourthCurvedLayer.textRadius = -80.0;
    fourthCurvedLayer.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
// Return YES for supported orientations
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [self setFirstCurvedLayer:nil];

    secondCurvedLayer = nil;

    thirdCurvedLayer = nil;

    fourthCurvedLayer = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {

//    [super dealloc];
}
@end
