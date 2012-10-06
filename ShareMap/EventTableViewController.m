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

@interface EventTableViewController ()

@end

@implementation EventTableViewController

@synthesize responseData = _responseData;
@synthesize rowList = _rowList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSURL *apiUrl = [NSURL URLWithString:@"http://localhost:3000/travel_event/"];
    //NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl];

    
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://localhost:3000/travel_event/"]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];

    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    self.rowList = [[NSArray alloc] init];
    
    // convert to JSON
    NSError *myError = nil;
    NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    for (NSDictionary *result in res) {    
        TravelEvent *event = [[TravelEvent alloc] init];
        event.event_id= [[result objectForKey:@"id"] intValue];
        event.name = [result objectForKey:@"name"];
        event.description = [result objectForKey:@"description"];
        event.destination_id = [[result objectForKey:@"destination_id"] intValue];
        event.owner_id = [[result objectForKey:@"owner_id"] intValue];
        self.rowList = [self.rowList arrayByAddingObject:event];
    }
    [self.tableView reloadData];
    /*
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if([self.rowList count] == 0) return 1;
    return [self.rowList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.rowList count] > 0)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        TravelEvent *event = [self.rowList objectAtIndex:[indexPath row]];
        UIImage *image = [UIImage imageNamed:@"res/gathering.jpg"];
        cell.imageView.image = image;
        [[cell textLabel] setText:event.name];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", event.description]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
    // Navigation logic may go here. Create and push another view controller.
    
     //EventTabBarController *controller = (EventTabBarController *)segue.destinationViewController;
     
    // ...
     // Pass the selected object to the new view controller.
     //[self.navigationController pushViewController:controller animated:YES];
    [self performSegueWithIdentifier:@"EventTab" sender:self];
     
}

- (IBAction)doEvent:(id)sender
{
}


@end
