//
//  KTThumbsViewController.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTPhotoBrowserDataSource.h"
#import "KTThumbsView.h"
#import "ATMHudDelegate.h"

@class ATMHud;

@class KTThumbsView;

@interface KTThumbsViewController : UIViewController <KTThumbsViewDataSource,ATMHudDelegate>
{
    ATMHud *hud;
@private
   id <KTPhotoBrowserDataSource> dataSource_;
   KTThumbsView *scrollView_;
   BOOL viewDidAppearOnce_;
   BOOL navbarWasTranslucent_;
    
}

@property (nonatomic, retain) id <KTPhotoBrowserDataSource> dataSource;
@property (nonatomic, retain) ATMHud *hud;

/**
 * Re-displays the thumbnail images.
 */
- (void)reloadThumbs;

/**
 * Called before the thumbnail images are loaded and displayed.
 * Override this method to prepare. For instance, display an
 * activity indicator.
 */
- (void)willLoadThumbs;

/**
 * Called immediately after the thumbnail images are loaded and displayed.
 */
- (void)didLoadThumbs;

/**
 * Used internally. Called when the thumbnail is touched by the user.
 */
- (void)didSelectThumbAtIndex:(NSUInteger)index;

@end
