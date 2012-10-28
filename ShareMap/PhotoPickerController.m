//
//  PhotoPickerController.m
//  Sample
//
//  Created by Kirby Turner on 2/2/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "PhotoPickerController.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"

#define BUTTON_SHARE 0
#define BUTTON_TAKEPHOTO 1
#define BUTTON_USELIBRARY 2
#define BUTTON_CANCEL 3

@interface PhotoPickerController (Private)
- (UIImagePickerController *)imagePicker;
- (void)showWithCamera;
- (void)showWithPhotoLibrary;
@end

@implementation PhotoPickerController
@synthesize hud;

- (void)dealloc {
   [imagePicker_ release], imagePicker_ = nil;
   
   [super dealloc];
}

- (id)initWithDelegate:(id)delegate {
   if (self = [super init]) {
      delegate_ = delegate;
   }
   return self;
}

- (void)show {
   // If the camera is supported on the device then prompt user to select
   // camera or photo library. If camera is not support then go straight
   // to the photo library.
   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"取消", @"Cancel button text.")
                                                 destructiveButtonTitle:NSLocalizedString(@"分享到地圖", @"Share button text.")
                                                      otherButtonTitles:NSLocalizedString(@"照相", @"Take Photo button text."), 
                                                                        NSLocalizedString(@"從相片庫選擇...", @"Button text."), 
                                                                        nil];
      if ([delegate_ respondsToSelector:@selector(view)]) {
         //[actionSheet showInView:[delegate_ view]];
         [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
      }
   } else {
      [self showWithPhotoLibrary];
   }
}

- (void)showWithCamera {
   isFromCamera_ = YES;
   [[self imagePicker] setSourceType:UIImagePickerControllerSourceTypeCamera];
   if ([delegate_ respondsToSelector:@selector(presentModalViewController:animated:)]) {
      [delegate_ presentModalViewController:imagePicker_ animated:YES];
   }
}

- (void)showWithPhotoLibrary {
   isFromCamera_ = NO;
   [[self imagePicker] setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   if ([delegate_ respondsToSelector:@selector(presentModalViewController:animated:)]) {
      [delegate_ presentModalViewController:imagePicker_ animated:YES];
   }
}

- (UIImagePickerController *)imagePicker {
   if (imagePicker_) {
      return imagePicker_;
   }
   
   imagePicker_ = [[UIImagePickerController alloc] init];
   [imagePicker_ setDelegate:self];
   return imagePicker_;
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   [picker dismissModalViewControllerAnimated:YES];

   UIImage *newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
   if ([delegate_ respondsToSelector:@selector(photoPickerController:didFinishPickingWithImage:isFromCamera:)]) {
      [delegate_ photoPickerController:self didFinishPickingWithImage:newImage isFromCamera:isFromCamera_];
   }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   [picker dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   switch (buttonIndex) {      
      case BUTTON_TAKEPHOTO:
         [self showWithCamera];
         break;
      case BUTTON_USELIBRARY:
         [self showWithPhotoLibrary];
         break;
      case BUTTON_CANCEL:
           // Do nothing.
         break;
      case BUTTON_SHARE:
           // HUD
           hud = [[ATMHud alloc] initWithDelegate:self];
//           [self.imagePicker.view addSubview:hud.view];
           NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
           [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
           [hud setCaption:@"圖片上傳中..."];
           [hud setBlockTouches:YES];
           [[[UIApplication sharedApplication] keyWindow] addSubview:hud.view];

           [hud show];


         
         break;
      default:
#ifdef DEBUG
         NSLog(@"Unexpected button index.");
#endif
         break;
   }
}

- (void)tick:(NSTimer *)timer {
	static CGFloat p = 0.08;
	p += 0.01;
	[hud setProgress:p];
	if (p >= 1) {
		p = 0;
		[timer invalidate];
		[hud hide];

		[self performSelector:@selector(resetProgress) withObject:nil afterDelay:0.2];
	}
}

- (void)resetProgress {
	[hud setProgress:0];
    hud = [[ATMHud alloc] initWithDelegate:self];
    [[[UIApplication sharedApplication] keyWindow] addSubview:hud.view];
    [hud setImage:[UIImage imageNamed:@"19-check"]];
    hud.accessoryPosition = ATMHudAccessoryPositionRight;
    [hud setCaption:@"上傳成功"];
    [hud show];
    [hud hideAfter:2];
}

@end
