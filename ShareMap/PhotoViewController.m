//
//  PhotoViewController.m
//  ShareMap
//
//  Created by Roger Liu on 12/10/8.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "PhotoViewController.h"
#import "KTThumbsView.h"
#import "KTThumbView.h"
#import "KTPhotoScrollViewController.h"

@interface PhotoViewController (Private)
- (UIActivityIndicatorView *)activityIndicator;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end

@implementation PhotoViewController

- (void)dealloc {
     myPhotos_ = nil;
    activityIndicatorView_ = nil;

}

- (id)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (self) {
        window_ = window;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
// 
//     imagePicker.delegate = self;
//       imagePicker.allowsEditing = NO;
 
//    UIButton *button = (UIButton *) [self.view viewWithTag:120];
	// Do any additional setup after loading the view.
//    [self setTitle:NSLocalizedString(@"Photo Album", @"Photo Album screen title.")];
//    
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
//                                                                               target:self
//                                                                            action:@selector(addPhoto) ];


//    [button addTarget:self action:@selector(addPhoto:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
//    UIToolbar *toolbar = [[UIToolbar alloc] init];
//    toolbar.barStyle = UIBarStyleBlackOpaque;
    
//    toolbar.frame = CGRectMake(0, 436, 320, 44);


    
    
    if (myPhotos_ == nil) {
        myPhotos_ = [[Photos alloc] init];
        [myPhotos_ setDelegate:self];
    }
    [self setDataSource:myPhotos_];

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

- (IBAction) ViewPhoto:(id) sender
{
    UIButton *myBtn=(UIButton *) sender;
         //预留模块
        NSLog(@"Button %d pressed",myBtn.tag);
    [self addPhoto];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.title = NSLocalizedString(@"京站聚餐", @"comment");
    [self.navigationController setNavigationBarHidden:YES animated:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    [myPhotos_ flushCache];
}


- (void)willLoadThumbs {
    [self showActivityIndicator];
}

- (void)didLoadThumbs {
    [self hideActivityIndicator];
}


#pragma mark -
#pragma mark Activity Indicator

- (UIActivityIndicatorView *)activityIndicator {
    if (activityIndicatorView_) {
        return activityIndicatorView_;
    }
    
    activityIndicatorView_ = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView_ setCenter:self.view.center];
    
    return activityIndicatorView_;
}

- (void)showActivityIndicator {
    if (window_) {
        [window_ addSubview:[self activityIndicator]];
    }
    [[self activityIndicator] startAnimating];
}

- (void)hideActivityIndicator {
    [[self activityIndicator] stopAnimating];
    [[self activityIndicator] removeFromSuperview];
}


#pragma mark -
#pragma mark Actions

- (void)addPhoto {
    if (!photoPicker_) {
        photoPicker_ = [[PhotoPickerController alloc] initWithDelegate:self];
    }
    [photoPicker_ show];
}


#pragma mark -
#pragma mark PhotoPickerControllerDelegate

- (void)photoPickerController:(PhotoPickerController *)controller didFinishPickingWithImage:(UIImage *)image isFromCamera:(BOOL)isFromCamera {
    [self showActivityIndicator];
    
    NSString * const key = @"nextNumber";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *nextNumber = [defaults valueForKey:key];
    if ( ! nextNumber ) {
        nextNumber = [NSNumber numberWithInt:1];
    }
    [defaults setObject:[NSNumber numberWithInt:([nextNumber intValue] + 1)] forKey:key];
    
    NSString *name = [NSString stringWithFormat:@"picture-%05i", [nextNumber intValue]];
    
    // Save to the photo album if picture is from the camera.
    [myPhotos_ savePhoto:image withName:name addToPhotoAlbum:isFromCamera];
}


#pragma mark -
#pragma mark PhotosDelegate

- (void)didFinishSave {
    [self reloadThumbs];
}



@end
