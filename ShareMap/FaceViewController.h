

#import <UIKit/UIKit.h>

//建立一個協定
@protocol FaceDelegate

//協定中的方法
- (void)passValue:(NSString *)value;

@end

@class ChatViewController;


@interface FaceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
	NSMutableArray            *_phraseArray;
	ChatViewController        *_chatViewController;
    
    
}

@property (retain, nonatomic) IBOutlet UIScrollView *faceScrollView;
@property (nonatomic, retain) NSMutableArray            *phraseArray;
@property (nonatomic, retain) ChatViewController        *chatViewController;

-(IBAction)dismissMyselfAction:(id)sender;
- (void)showEmojiView;

//宣告一個採用Page2Delegate協定的物件
@property (weak) id<FaceDelegate> delegate;
@end


