//
//  PhotoViewController.m
//  ShareMap
//
//  Created by Roger Liu on 12/10/8.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

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
	// Do any additional setup after loading the view.
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:100];
	toolbar.frame = CGRectMake(0.0f, (float)(423.0f), 320.0f, 44.0f);
//    UIToolbar *toolbar =[[UIToolbar alloc] init];
//    toolbar.barStyle=UIBarStyleBlackTranslucent;
//    [toolbar sizeToFit];
//    CGFloat toolbarHeight =[toolbar frame].size.height;
//    CGRect rootViewBounds =self.parentViewController.view.bounds;
//    //CGFloat rootViewHeight =CGRectGetHeight(rootViewBounds);
//    CGFloat rootViewWidth =CGRectGetWidth(rootViewBounds);
//    //  CGRect rectArea = CGRectMake(0, rootViewHeight-toolbarHeight,rootViewWidth, toolbarHeight);
//    //NSLog(@"rootViewHeight = %f , toolbarHeight = %f",rootViewHeight, toolbarHeight);
//    
//    CGRect rectArea = CGRectMake(0, 387,rootViewWidth, toolbarHeight);
//    [toolbar setFrame:rectArea];
//    toolbar.backgroundColor= [UIColor clearColor];
    
//    UILabel *readLabel =[[UILabel alloc]initWithFrame:CGRectMake(230,0, 200,30)];
//    readLabel.backgroundColor = [UIColor clearColor];
//    readLabel.textColor =[UIColor whiteColor];
//    [readLabel setFont:[UIFont systemFontOfSize:11]];
//    readLabel.text = @"標題：烈日下的街頭藝人真辛苦QQ";
//
//    UIButton *Btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    
//    //[Btn setFrame:CGRectMake(10, 100, self.view.bounds.size.width- 20, 52)];
//    Btn = [UIButton buttonWithType:UIButtonTypeCustom] ; //按鈕的類型
//    [Btn setImage:[UIImage imageNamed:@"coolpc-printershare.png"] forState:UIControlStateNormal];//設置按鈕圖片
//    Btn.tag = 10;
//    //[Btn setTitle:@"發送" forState:UIControlStateNormal];
//    CGRect frame;
//    frame.size.width = 40;  //設置按鈕的寬度
//    frame.size.height = 39;   //設置按鈕的高度
//    //frame.origin.x =10;   //設置按鈕的位置
//    //frame.origin.y =23;
//    [Btn setFrame:frame];
//    //[Btn setBackgroundColor:[UIColor clearColor]];
//    //Btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [Btn addTarget:self action:@selector(btnPressed:)forControlEvents:UIControlEventTouchUpInside];   //按鈕的單擊事件
//    
//    
//    UIButton *Btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    
//    //[Btn setFrame:CGRectMake(10, 100, self.view.bounds.size.width- 20, 52)];
//    Btn2 = [UIButton buttonWithType:UIButtonTypeCustom] ; //按鈕的類型
//    [Btn2 setImage:[UIImage imageNamed:@"56-cloud.png"] forState:UIControlStateNormal];//設置按鈕圖片
//    Btn2.tag = 11;
//    //[Btn setTitle:@"發送" forState:UIControlStateNormal];
//    CGRect frame2;
//    frame2.size.width = 40;  //設置按鈕的寬度
//    frame2.size.height = 39;   //設置按鈕的高度
//    //frame2.origin.x =230;   //設置按鈕的位置
//    //frame2.origin.y =50;
//    [Btn setFrame:frame2];
//    //[Btn setBackgroundColor:[UIColor clearColor]];
//    //Btn2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [Btn2 addTarget:self action:@selector(btnPressed:)forControlEvents:UIControlEventTouchUpInside];   //按鈕的單擊事件
//    
//    
//    NSMutableArray *tbitems =[NSMutableArray array];
//    [tbitems addObject:[[UIBarButtonItem alloc] initWithCustomView:readLabel]];
//    
//    [tbitems addObject:[[UIBarButtonItem alloc] initWithCustomView:Btn]];
//    [tbitems addObject:[[UIBarButtonItem alloc] initWithCustomView:Btn2]];
//    toolbar.items = tbitems;
//    
//    [self.navigationController.view addSubview:toolbar];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) btnPressed:(id) sender
{
    UIButton *myBtn=(UIButton *) sender;
    if (myBtn.tag==0)
    {
        //预留模块
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
@end
