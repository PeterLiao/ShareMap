//
//  AddEventViewController.m
//  ShareMap
//
//  Created by Mac on 12/10/5.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "AddEventViewController.h"
static double finalLat = 0.f;
static double finalLon = 0.f ;

@interface AddEventViewController ()

@end

@implementation AddEventViewController

@synthesize eventTitleTextField = _eventTitleTextField;
@synthesize eventDetailTextField = _eventDetailTextField;
@synthesize eventDateLabel = _eventDateLabel;
@synthesize eventLocationLabel = _eventLocationLabel;
@synthesize location = _location;

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

- (IBAction)doCancelView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addEvent:(id)sender
{
    _responseData = [NSMutableData data];
    NSString *requestURL = @"http://sevenpeaches.herokuapp.com/travel_event/new?";
    NSString *eventTitle = [_eventTitleTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *eventDetailTitle = [_eventDetailTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lat = [[NSString alloc] initWithFormat:@"%f", finalLat];
    NSString *lon = [[NSString alloc] initWithFormat:@"%f", finalLon];
    requestURL = [[requestURL stringByAppendingString:@"name="] stringByAppendingString:eventTitle];
    requestURL = [[requestURL stringByAppendingString:@"&description="] stringByAppendingString:eventDetailTitle];
    requestURL = [[requestURL stringByAppendingString:@"&event_time="] stringByAppendingString:@"0"];
    requestURL = [[requestURL stringByAppendingString:@"&destination_id="] stringByAppendingString:@"4"];
    requestURL = [[requestURL stringByAppendingString:@"&owner_id="] stringByAppendingString:@"1"];
    requestURL = [[requestURL stringByAppendingString:@"&latitude="] stringByAppendingString:lat];
    requestURL = [[requestURL stringByAppendingString:@"&longtitude="] stringByAppendingString:lon];    
    NSString *locationName = [self.eventLocationLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    requestURL = [[requestURL stringByAppendingString:@"&location_name="] stringByAppendingString:locationName];
    NSLog(@"request url=%@", requestURL);
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:requestURL]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Received %d bytes of data",[self.responseData length]);
    
//    NSError *myError = nil;
//    NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //將page2設定成Storyboard Segue的目標UIViewController
    id page2 = segue.destinationViewController;
    
    //將值透過Storyboard Segue帶給頁面2的string變數
    //    [page2 setValue:page1TextField.text forKey:@"string"];
    
    //將delegate設成自己（指定自己為代理）
    [page2 setValue:self forKey:@"delegate"];
    
}

- (void)passLoc:(MKPointAnnotation *)value currentLat:(double)currentLat currentLon:(double) currentLon currentLoc: (NSString*) currentLoc {
    
    //設定page1TextField為所取的的數值
    //self.messageString = value;
    NSLog(@"currentLat = %f", currentLat);
    NSLog(@"value = %f", value.coordinate.latitude);
//    self.eventLocationLabel.text = value.title;
    if (value.coordinate.latitude == 0){
        finalLat = value.coordinate.latitude;
    } else{
        finalLat = currentLat;
    }
    if (value.coordinate.latitude == 0){
        finalLon = value.coordinate.longitude;
    } else{
        finalLon = currentLon;
    }
    
    if (value.title == nil){
        self.eventLocationLabel.text = currentLoc;
    } else {
        self.eventLocationLabel.text = value.title;
    }

    [self.location setCoordinate:value.coordinate];
    NSLog(@"location:%f, %f",finalLat, finalLat );
}


- (IBAction)backgroundTap:(id)sender {
    [eventTitleTextField resignFirstResponder];
    [eventDateLabel resignFirstResponder];
}

@end
