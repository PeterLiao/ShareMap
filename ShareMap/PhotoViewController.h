//
//  PhotoViewController.h
//  ShareMap
//
//  Created by Roger Liu on 12/10/8.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTThumbsViewController.h"
#import "PhotoPickerController.h"
#import "Photos.h"
#import "GlobalTab.h"



@class Photos;


@interface PhotoViewController : KTThumbsViewController <PhotoPickerControllerDelegate, PhotosDelegate,UINavigationControllerDelegate> {
    PhotoPickerController *photoPicker_;
    Photos *myPhotos_;
    UIActivityIndicatorView *activityIndicatorView_;
    UIWindow *window_;
    
    singletonObj *sobj;

//@private
//    id <KTPhotoBrowserDataSource> dataSource_;
//    KTThumbsView *scrollView_;
//    BOOL viewDidAppearOnce_;
//    BOOL navbarWasTranslucent_;
}


- (IBAction)ViewPhoto:(id)sender;

- (id)initWithWindow:(UIWindow *)window;

@property (nonatomic, retain) id <KTPhotoBrowserDataSource> dataSource;

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


