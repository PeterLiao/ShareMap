//
//  AddEventViewController.m
//  ShareMap
//
//  Created by Mac on 12/10/5.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "AddEventViewController.h"

@interface AddEventViewController ()

@end

@implementation AddEventViewController

@synthesize eventTitleTextField = _eventTitleTextField;
@synthesize eventDetailTextField = _eventDetailTextField;
@synthesize eventDateLabel = _eventDateLabel;
@synthesize eventLocationLabel = _eventLocationLabel;

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doCancelView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addEvent:(id)sender
{
    _responseData = [NSMutableData data];
    NSString *requestURL = @"http://localhost:3000/travel_event/new?";
    NSString *eventTitle = [_eventTitleTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *eventDetailTitle = [_eventDetailTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestURL = [[requestURL stringByAppendingString:@"name="] stringByAppendingString:eventTitle];
    requestURL = [[requestURL stringByAppendingString:@"&description="] stringByAppendingString:eventDetailTitle];
    requestURL = [[requestURL stringByAppendingString:@"&event_time="] stringByAppendingString:@"0"];
    requestURL = [[requestURL stringByAppendingString:@"&destination_id="] stringByAppendingString:@"4"];
    requestURL = [[requestURL stringByAppendingString:@"&owner_id="] stringByAppendingString:@"1"];
    NSLog(@"request url=%@", requestURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:requestURL]];
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
    
    NSError *myError = nil;
    NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(UITextField *)textField
{
    [textField resignFirstResponder];
}
@end
