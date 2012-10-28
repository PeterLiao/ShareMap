//
//  PhotoPickerController.h
//  Sample
//
//  Created by Kirby Turner on 2/2/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHudDelegate.h"

@class ATMHud;

@interface PhotoPickerController : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, ATMHudDelegate> {
   id delegate_;
   UIImagePickerController *imagePicker_;
   BOOL isFromCamera_;
    ATMHud *hud;
}

@property (nonatomic, retain) ATMHud *hud;
- (id)initWithDelegate:(id)delegate;
- (void)show;

@end

@protocol PhotoPickerControllerDelegate <NSObject> 
@optional
- (void)photoPickerController:(PhotoPickerController *)controller didFinishPickingWithImage:(UIImage *)image isFromCamera:(BOOL)isFromCamera;
@end;
