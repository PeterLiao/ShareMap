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


@class Photos;

@interface PhotoViewController : UIViewController <PhotoPickerControllerDelegate, PhotosDelegate,UINavigationControllerDelegate> {
    PhotoPickerController *photoPicker_;
    Photos *myPhotos_;
    UIActivityIndicatorView *activityIndicatorView_;
    UIWindow *window_;
@private
    id <KTPhotoBrowserDataSource> dataSource_;
    KTThumbsView *scrollView_;
    BOOL viewDidAppearOnce_;
    BOOL navbarWasTranslucent_;
}


- (IBAction)ViewPhoto:(id)sender;

- (id)initWithWindow:(UIWindow *)window;
@property (nonatomic, retain) id <KTPhotoBrowserDataSource> dataSource;
/**
 * Re-displays the thumbnail images.
 */
- (void)reloadThumbs;
@end


