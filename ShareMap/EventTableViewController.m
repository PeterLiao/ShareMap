//
//  EventViewController.m
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

#import "EventTableViewController.h"
#import "TravelEvent.h"
#import "EventTabBarController.h"
#import "AddEventViewController.h"


#define URL_GET_EVENT     @"http://sevenpeaches.herokuapp.com/travel_event/"
#define URL_DESTROY_EVENT @"http://sevenpeaches.herokuapp.com/travel_event/destroy/%d"

@interface EventTableViewController ()

@end

@implementation EventTableViewController

@synthesize responseData = _responseData;
@synthesize rowList = _rowList;
@synthesize dataList = _dataList;
@synthesize connStatus = _connStatus;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)reloadEvent
{
    _responseData = [NSMutableData data];
    _connStatus = STATUS_CONN_SUCCESS;
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:URL_GET_EVENT]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(!conn)
    {
        _connStatus = STATUS_CONN_FAIL;
    }
}

-(void)deleteEvent:(int)index
{
    NSLog(@"_rowList.count:%d", _rowList.count);
    if(index > _rowList.count)return;
    _responseData = [NSMutableData data];
    _connStatus = STATUS_CONN_SUCCESS;
    TravelEvent *event = [_rowList objectAtIndex:index];
    NSLog(@"deleteEvent, event_id:%d", event.event_id);
    NSString *strUrl =[NSString stringWithFormat:URL_DESTROY_EVENT, event.event_id];
    ;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(!conn)
    {
        _connStatus = STATUS_CONN_FAIL;
    }
    else
    {
        [_dataList removeObjectAtIndex:index];
        _rowList = [NSArray arrayWithArray:_dataList];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sobj = [singletonObj singleObj];  // 宣告全域物件
    [self reloadEvent];
    self.navigationController.delegate = self;
    
    UIBarButtonItem *reload = [[UIBarButtonItem alloc]initWithTitle:@"重新整理" style:UIBarButtonItemStyleDone target:self action:@selector(forceReloadEvent:)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    
    NSArray *items = [[NSArray alloc] initWithObjects:reload, nil];
    
    self.navigationItem.rightBarButtonItems = items;
    

}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [self reloadEvent];
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
    _connStatus = STATUS_CONN_FAIL;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading, URL:%@", connection.currentRequest.URL.absoluteString);
    NSLog(@"Received %d bytes of data",[self.responseData length]);
    if(connection.currentRequest.URL.absoluteString == URL_GET_EVENT)
    {
        _dataList = [[NSMutableArray alloc] init];
        // convert to JSON
        NSError *myError = nil;
        NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
        
        // show all values
        for (NSDictionary *result in res) {
            TravelEvent *event = [[TravelEvent alloc] init];
            if([result objectForKey:@"id"] != NULL) {
                event.event_id= [[result objectForKey:@"id"] intValue];
            }
            event.name = [result objectForKey:@"name"];
            event.description = [result objectForKey:@"description"];
            event.destination_id = [[result objectForKey:@"destination_id"] intValue];
            event.owner_id = [[result objectForKey:@"owner_id"] intValue];
            event.latitude = [[result objectForKey:@"latitude"] doubleValue];
            event.longtitude = [[result objectForKey:@"longtitude"] doubleValue];
            event.location_name = [result objectForKey:@"location_name"];

            [_dataList addObject:event];
        }
        _connStatus = STATUS_CONN_SUCCESS;
        _rowList = [NSArray arrayWithArray:_dataList];
        NSLog(@"Receive event count:%d", _rowList.count);
        [self.tableView reloadData];
    }
    /*
     //Parse josn data from server
     for(id key in res) {
     
     id value = [res objectForKey:key];
     
     NSString *keyAsString = (NSString *)key;
     NSString *valueAsString = (NSString *)value;
     
     NSLog(@"key: %@", keyAsString);
     NSLog(@"value: %@", valueAsString);
     ```
     
     // extract specific value...
     NSArray *results = [res objectForKey:key];
     
     for (NSDictionary *result in results) {
     NSString *name = [result objectForKey:@"name"];
     NSLog(@"name: %@", name);
     }
     }*/
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)	:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([self.rowList count] == 0) return 1;
    return [self.rowList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [self.rowList count];
    if(count > 0 && _connStatus == STATUS_CONN_SUCCESS)
    {
        static NSString *CellIdentifier = @"LoadOKCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        if([self.rowList count] > 0)
        {
            TravelEvent *event = [self.rowList objectAtIndex:[indexPath row]];
            UIImage *image = [UIImage imageNamed:@"res/gathering.jpg"];
            cell.imageView.image = image;
            [[cell textLabel] setText:event.name];
            [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", event.location_name]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            return cell;
        } else {
            static NSString *CellIdentifier = @"NonCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            [[cell detailTextLabel] setText:@"目前沒有事件，新增ㄧ個吧！"];
            return cell;
        }
        
    }
    else if(_connStatus == STATUS_CONN_FAIL)
    {
        static NSString *CellIdentifier = @"LoadFailCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [[cell detailTextLabel] setText:@"資料讀取失敗!"];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"LoadingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }

        [[cell detailTextLabel] setText:@"讀取中..."];
        return cell;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row:%d selected", [indexPath row]);
    if ( [_rowList count] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"無效的事件，請選擇其他欄位或新增一個事件"
                                                       delegate:self
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    TravelEvent *event = [_rowList objectAtIndex:[indexPath row]];
    sobj.eventTitle = event.name;
    sobj.eventLatitude = event.latitude;
    sobj.eventLongitude = event.longtitude;
    sobj.eventLocationName = event.location_name;

    // Navigation logic may go here. Create and push another view controller.
    
    //EventTabBarController *controller = (EventTabBarController *)segue.destinationViewController;
    
    // ...
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:controller animated:YES];
    [self performSegueWithIdentifier:@"EventTab" sender:self];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"刪除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSLog(@"delete event: row index:%d", indexPath.row);
        [(UITableView *)self.view beginUpdates];
        [(UITableView *)self.view deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [self deleteEvent:indexPath.row];
        if (indexPath.row) {
            [(UITableView *)self.view endUpdates];
        } else {
            [self reloadEvent];
//            [[self tableView] endUpdates];  // Crash Here.
        }
        
        //[self reloadEvent];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (IBAction)addEvent:(id)sender
{
    NSLog(@"Addevent");
}

- (IBAction)forceReloadEvent:(id)sender
{
    NSLog(@"forceReloadEvent");
    [self reloadEvent];

}


- (void)navigationController:(UINavigationController *)navigationController
willShowViewController:(UIViewController *)viewController animated:(BOOL
                                                                    )animated
{
    [viewController viewWillAppear:animated];
}

@end
