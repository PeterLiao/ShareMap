//
//  EventMapViewController.m
//  ShareMap
//
//  Created by Mac on 12/9/21.
//  Copyright (c) 2012年 Mac. All rights reserved.
//

/*
 tabbar頁面間的切換:
 [self.tabBarController setSelectedIndex:2]; 
 */

#import "EventMapViewController.h"
#import "CustomPlacemark.h"
#import "QuartzCore/CAAnimation.h"
#import "QuartzCore/CAMediaTimingFunction.h"
#import "UsefulMacros.h"
#import "QuartzCore/CAShapeLayer.h"
#import "QuartzCore/CATransaction.h"
#import "math.h"
#import "ChatViewController.h"
#import "Reachability.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "GCDiscreetNotificationView.h"

#define toRad(X) (X*M_PI/180.0)
#define toDeg(X) (X*180.0/M_PI)
#define degreesToRadians(x) (M_PI * x / 180.0)


#define NEARRADIUS 130.0f
#define ENDRADIUS 140.0f
#define FARRADIUS 160.0f
#define STARTPOINT CGPointMake(30, 380)
#define TIMEOFFSET 0.026f



static bool isNext = 1; // Default is total distance
static float totalmeters = 0.f;
static float nextmeters = 0.f;


@interface EventMapViewController ()
- (void)_expand;
- (void)_close;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;

@end

@implementation EventMapViewController

@synthesize placemarkList;
@synthesize responseData = _responseData;
@synthesize mapView = _mapView;
@synthesize searchTextField;
@synthesize Distance;
@synthesize pulseLayer_;
@synthesize lineColor;
@synthesize locationManager = _locationManager;
@synthesize startingPoint = _startingPoint;
@synthesize motionManager = _motionManager;

@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;
@synthesize labelShow;
@synthesize hud;
@synthesize nextDistance;
@synthesize notificationView;


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
    sobj = [singletonObj singleObj];
    self.Distance.userInteractionEnabled = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 導航精細度
    // 檢查是否為 Wifi
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable) {
        NSLog(@"Wifi!");
        self.locationManager.distanceFilter = 100.0f; //在生成更新位置前，設備必須移動的米數
    // 檢查是否為 3G
    } else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
        NSLog(@"3G!");
        self.locationManager.distanceFilter = 10.0f; //在生成更新位置前，設備必須移動的米數
    } else {
        NSLog(@"Cannot connect Network!!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"目前無網路連線，請先連上網路再行使用"
                                                       delegate:self
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil];
        [alert show];

        return;
    }
    
    self.locationManager.headingFilter = 5;//在生成更新的指南針讀數之前設備需要轉過的度數 (Notify heading changes when heading is > 5.)
    
    if ([CLLocationManager locationServicesEnabled]){
        [_locationManager startUpdatingLocation];
    }
    //偵測方位
    
    if ([CLLocationManager headingAvailable]){
        [_locationManager startUpdatingHeading];
    }

    //_mapView.showsUserLocation = YES;
    routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height)];
    routeView.userInteractionEnabled = NO;
    [_mapView addSubview:routeView];
    
    self.lineColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    
	// Do any additional setup after loading the view.
    //[_mapView removeAnnotations:[_mapView annotations]];
    placemarkList = [[NSArray alloc] init];

    
//    Place* home = [[Place alloc] init];
//
//	home.latitude = 25.043119;
//	home.longitude = 121.509529;
//    
//	Place* office = [[Place alloc] init];
//	office.latitude = 25.049272;
//	office.longitude = 121.516879;
//    
//    [self showRouteFrom:home to:office];
    
    pulseLayer_ = [CAShapeLayer layer];
    [_mapView.layer addSublayer:pulseLayer_];


    
    [self addPlacemark:25.043119 longitude:121.509529 title:@"Jessica" subTitle:@"趕路中(預計5分鐘)" status:STATUS_GOING];
    [self addPlacemark:25.049272 longitude:121.516879 title:@"Miniko" subTitle:@"趕路中(預計10分鐘)" status:STATUS_GOING];

    //偵測速度
    
//    self.motionManager = [[CMMotionManager alloc] init];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    if (_motionManager.accelerometerAvailable){
//        _motionManager.accelerometerUpdateInterval = 5;
//        [_motionManager startAccelerometerUpdatesToQueue:queue
//                        withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
//                            if (error) {
//                                [_motionManager stopAccelerometerUpdates];
//                                NSLog(@"Error: %@",error);
//                            } else {
//                                NSLog(@"x=%f, y=%f, z=%f",accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
//                            }
//                        }];
//    }
    
//    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    spin.toValue = [NSNumber numberWithFloat:M_PI * 2];
//    spin.duration = 1.f;
//    spin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    
//    [CATransaction begin];
//    if(IS_IOS4) {
//        [CATransaction setCompletionBlock:^{
//            CABasicAnimation *squish = [CABasicAnimation animationWithKeyPath:@"transform"];
//            CATransform3D squishTransform = CATransform3DMakeScale(1.75f, .25f, 1.f);
//            squish.toValue = [NSValue valueWithCATransform3D:squishTransform];
//            squish.duration = .5f;
//            squish.repeatCount = 1;
//            squish.autoreverses = YES;
//            
//            CABasicAnimation *fadeOutBG = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
//            fadeOutBG.toValue = (id)[[UIColor yellowColor] CGColor];
//            fadeOutBG.duration = .55f;
//            fadeOutBG.repeatCount = 1;
//            fadeOutBG.autoreverses = YES;
//            fadeOutBG.beginTime = 1.f;
//            
//            CAAnimationGroup *group = [CAAnimationGroup animation];
//            group.animations = [NSArray arrayWithObjects:squish, fadeOutBG, nil];
//            group.duration = 2.f;
//            group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//            
//            [pulseLayer_ addAnimation:group forKey:@"SquishAndHighlight"];
//        }];
//    }
//    [pulseLayer_ addAnimation:spin forKey:@"spinTheText"];
//    [CATransaction commit];
    
    
    // Menu
    
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    // Camera MenuItem.
    QuadCurveMenuItem *cameraMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[UIImage imageNamed:@"icon-star.png"]
                                                         highlightedContentImage:nil];
    // People MenuItem.
    QuadCurveMenuItem *peopleMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[UIImage imageNamed:@"icon-star.png"]
                                                         highlightedContentImage:nil];
    // Place MenuItem.
    QuadCurveMenuItem *placeMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[UIImage imageNamed:@"icon-star.png"]
                                                        highlightedContentImage:nil];
    // Music MenuItem.
    QuadCurveMenuItem *musicMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[UIImage imageNamed:@"icon-star.png"]
                                                        highlightedContentImage:nil];
    // Thought MenuItem.
    QuadCurveMenuItem *thoughtMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                 highlightedImage:storyMenuItemImagePressed
                                                                     ContentImage:[UIImage imageNamed:@"icon-star.png"]
                                                          highlightedContentImage:nil];
    // Sleep MenuItem.
    QuadCurveMenuItem *sleepMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:[UIImage imageNamed:@"icon-star.png"] 
                                                        highlightedContentImage:nil];
    
    NSArray *aMenusArray = [NSArray arrayWithObjects:cameraMenuItem, peopleMenuItem, placeMenuItem, musicMenuItem, thoughtMenuItem, sleepMenuItem, nil];

    
    _menusArray = [aMenusArray copy];
    
    // add the menu buttons
    int count = [_menusArray count];
    for (int i = 0; i < count; i ++)
    {
        QuadCurveMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
//        item.startPoint = STARTPOINT;
        item.startPoint = CGPointMake(120, 475);
        item.endPoint = CGPointMake(STARTPOINT.x + ENDRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - ENDRADIUS * cosf(i * M_PI_2 / (count - 1)));
        item.nearPoint = CGPointMake(STARTPOINT.x + NEARRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - NEARRADIUS * cosf(i * M_PI_2 / (count - 1)));
        item.farPoint = CGPointMake(STARTPOINT.x + FARRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - FARRADIUS * cosf(i * M_PI_2 / (count - 1)));
        item.center = item.startPoint;
        item.delegate = self;
        [_mapView addSubview:item];
    }
    
    // add the "Add" Button.
    _addButton = [[QuadCurveMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
                                         highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"]
                                             ContentImage:[UIImage imageNamed:@"icon-plus.png"]
                                  highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
    _addButton.delegate = self;
    _addButton.center = STARTPOINT;
    [self.view addSubview:_addButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    _addButton.userInteractionEnabled = YES;
    [_addButton addGestureRecognizer:tap];
    
    
    // HUD
    hud = [[ATMHud alloc] initWithDelegate:self];
    [self.view addSubview:hud.view];
    [hud setBlockTouches:YES];
    [hud setCaption:@"切換到朋友介面以回到上一層選單"];
    [hud show];
    [hud hideAfter:3.5];
    
    // Notification
    notificationView = [[GCDiscreetNotificationView alloc] initWithText:@"test"
                                                           showActivity:NO
                                                     inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                 inView:self.view];
    [self.notificationView hide:YES];
}

- (void )imageTapped:(UITapGestureRecognizer *) gestureRecognizer
{
//    self.expanding = !self.isExpanding;
}

-(void)addPlacemark:(double)latitude longitude:(double)longitude title:(NSString *)title subTitle:(NSString *) subTtile status:(int) status
{
    CLLocationCoordinate2D coordinae2D;
    coordinae2D.latitude = latitude;
    coordinae2D.longitude = longitude;
    
    CustomPlacemark * placemark = [[CustomPlacemark alloc] initWithCoordinate:coordinae2D addressDictionary:nil];
    [placemark setTitle:title];
    [placemark setSubtitle:subTtile];
    [placemark setStatus:status];
    
    [self addPlacemarkToList:placemark];
    //[self resetMapScope:coordinae2D];
    [_mapView setCenterCoordinate:_mapView.centerCoordinate animated:YES];
    [_mapView selectAnnotation:placemark animated:YES]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//IOS 5 and below
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}

//IOS 6
- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}





-(void)addPlacemarkToList:(CustomPlacemark *)placemark
{        
    placemarkList = [placemarkList arrayByAddingObject:placemark];
    [_mapView addAnnotation:placemark];
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
    
    self.placemarkList = [[NSArray alloc] init];
    
    // convert to JSON
    //NSError *myError = nil;
    //NSArray *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    /*
    for (NSDictionary *result in res) {
        TravelEvent *event = [[TravelEvent alloc] init];
        event.event_id= [[result objectForKey:@"id"] intValue];
        event.name = [result objectForKey:@"name"];
        event.description = [result objectForKey:@"description"];
        event.destination_id = [[result objectForKey:@"destination_id"] intValue];
        event.owner_id = [[result objectForKey:@"owner_id"] intValue];
        self.rowList = [self.rowList arrayByAddingObject:event];
    }
    [_mapView addAnnotations:placemarkList];*/
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0)
{
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知選項" message:@"" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:@"傳送導航", @"事故求救", @"Call Out", @"丟訊息", nil];
    [alert show];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSString *title = annotation.title;
    MKPinAnnotationView *pinView=(MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:title];
    if(pinView==nil)
        pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:title];
    
    if([annotation isKindOfClass:[CustomPlacemark class]])
    {
        CustomPlacemark * placemark = (CustomPlacemark *)annotation;
        
        if(placemark.status == STATUS_ARRIVED)
            [pinView setPinColor:MKPinAnnotationColorGreen];
        else if(placemark.status == STATUS_MISSING || placemark.status == STATUS_GOING)
            [pinView setPinColor:MKPinAnnotationColorRed];
        else
            [pinView setPinColor:MKPinAnnotationColorPurple];
    }
    else
    {
        [pinView setPinColor:MKPinAnnotationColorRed];
    }

    pinView.canShowCallout=YES;
    //pinView.animatesDrop=YES;
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return pinView;
}

-(void)resetMapScope:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateSpan span; // create a range of your view
    span.latitudeDelta = 0.0144927536 * 5/3;  // span dimensions.  I have BASE_RADIUS defined as 0.0144927536 which is equivalent to 1 mile
    span.longitudeDelta = 0.0144927536 * 5/3;  // span dimensions
 
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]; //Get your location and create a CLLocation
    
    MKCoordinateRegion region; //create a region.  No this is not a pointer
    region.center = location.coordinate;  // set the region center to your current location
    
    region.span = span; // Set the region's span to the new span.
    
    [_mapView setRegion:region animated:YES]; // to set the map to the newly created region
    //[mapView setMapType:MKMapTypeHybrid];
}


- (double)computeAzimuth:(float)lat1 lon1:(float)lon1 lat2:(float)lat2 lon2:(float)lon2
{
    double result = 0.0;
    

    int ilat1 = (int) (0.50 + lat1 * 360000.0);
    int ilat2 = (int) (0.50 + lat2 * 360000.0);
    int ilon1 = (int) (0.50 + lon1 * 360000.0);
    int ilon2 = (int) (0.50 + lon2 * 360000.0);
    
    lat1 = toRad(lat1);
    lon1 = toRad(lon1);
    lat2 = toRad(lat2);
    lon2 = toRad(lon2);
    
    if ((ilat1 == ilat2) && (ilon1 == ilon2)) {
        return result;
    } else if (ilon1 == ilon2) {
        if (ilat1 > ilat2)
            result = 180.0;
    } else {
        double c = acos(sin(lat2) * sin(lat1) + cos(lat2) * cos(lat1) * cos((lon2 - lon1)));
        double A = asin(cos(lat2) * sin((lon2 - lon1)) / sin(c));
        result =  toDeg(A);
        if ((ilat2 > ilat1) && (ilon2 > ilon1)) {
        } else if ((ilat2 < ilat1) && (ilon2 < ilon1)) {
            result = 180.0 - result;
        } else if ((ilat2 < ilat1) && (ilon2 > ilon1)) {
            result = 180.0 - result;
        } else if ((ilat2 > ilat1) && (ilon2 < ilon1)) {
            result += 360.0;
        }
    }
    return result;

}
- (IBAction)doSearch:(id)sender
{
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:searchTextField.text completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if(placemarks.count > 0)
        {
            NSLog(@"Found placemarks for %@",searchTextField.text);
            CLPlacemark* placemark =  [placemarks objectAtIndex:0];
            double latitude = placemark.location.coordinate.latitude;
            double longitude = placemark.location.coordinate.longitude;
            [self addPlacemark:latitude longitude:longitude title:searchTextField.text subTitle:@"約會地點" status:STATUS_TARGET];
        }
        else
        {
            NSLog(@"Found no placemarks for %@",searchTextField.text);
        }
    }];
    [searchTextField resignFirstResponder];
}

//- (void)loadView {
//    UIView *myView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    myView.backgroundColor = [UIColor whiteColor];
//    
//    pulseLayer_ = [CALayer layer];
//    [myView.layer addSublayer:pulseLayer_];
//    
//    self.view = myView;
//}



- (void)viewWillAppear:(BOOL)animated
{

    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    CGRect rect;
    rect.size = CGSizeMake(500, 600);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 25);
    CGPathAddLineToPoint(path, NULL, 35, 50);
    CGPathAddLineToPoint(path, NULL, 15, 50);
    CGPathAddLineToPoint(path, NULL, 25, 75);
    CGPathAddLineToPoint(path, NULL, -25, 75);
    CGPathAddLineToPoint(path, NULL, -15, 50);
    CGPathAddLineToPoint(path, NULL, -35, 50);
    
    //pulseLayer_.backgroundColor = [UIColorFromRGBA(0xFFE365FF, .75) CGColor];
//    pulseLayer_.bounds = CGRectMake(0., 0., 50., 50.);
//    pulseLayer_.cornerRadius = 12.;
//    pulseLayer_.position=CGPointMake(50.0f,50.0f);
    //pulseLayer_.position = self.view.center;
    
    [pulseLayer_ setBounds:CGRectMake(0, 0, 50, 50)];
    //pulseLayer_.fillColor = [[UIColor purpleColor] CGColor];
    [pulseLayer_ setFillColor:[UIColorFromRGBA(0xFFE365FF, .75) CGColor]];


    [pulseLayer_ setPosition:CGPointMake(250, 250)];
    [pulseLayer_ setPath:path];

//    [[[self view] layer]addSublayer:pulseLayer_];
    [[[_mapView superview] layer]addSublayer:pulseLayer_];
//    [pulseLayer_ setNeedsDisplay];
    self.tabBarController.title = NSLocalizedString(@"京站聚餐", @"comment");
    
    //跑馬燈
//    if (sobj.gblStr){
//        labelShow.text = [NSString stringWithFormat:@"%@%@", @"Other: ", sobj.gblStr];
//    }
//
//    CGRect frame = labelShow.frame;
//	frame.origin.x = -180;
//	labelShow.frame = frame;
//	
//	[UIView beginAnimations:@"testAnimation" context:NULL];
//	[UIView setAnimationDuration:8.8f];
//	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationRepeatAutoreverses:NO];
//	[UIView setAnimationRepeatCount:999999];
//	
//	frame = labelShow.frame;
//	frame.origin.x = 350;
//	labelShow.frame = frame;
//	[UIView commitAnimations];
    
    if (sobj.gblStr) {
        NSString *text = [NSString stringWithFormat:@"%@%@", @"Other: ", sobj.gblStr];
        notificationView = [[GCDiscreetNotificationView alloc] initWithText:text
                                                               showActivity:NO
                                                         inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                     inView:self.view];
        [self.notificationView hide:NO];
        [self.notificationView show:YES];
        [self.notificationView hideAnimatedAfter:3.0];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
    
    [pulseLayer_ addAnimation:pulseAnimation forKey:nil];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded lat_1:(NSString*) lat_1 lon_1:(NSString*) lon_1 {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
    NSDecimalNumber *lat_1_num = [[NSDecimalNumber alloc] initWithString:lat_1];
    NSDecimalNumber *lon_1_num = [[NSDecimalNumber alloc] initWithString:lon_1];
//    NSLog(@"lat_1: %f",[lat_1_num floatValue]);
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
    NSInteger turn=0;
    totalmeters = 0.f;
    nextmeters = 0.f;
    
    NSLog(@"len=%d, index=%d",len,index);
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5] ;
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
//		printf("[%f,", [latitude doubleValue]);
//		printf("%f]", [longitude doubleValue]);
        
        
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        BOOL isSamePoint = NO;
        if( 0 == [array count] ){
            NSLog(@"lat_num = %f",[lat_1_num floatValue]);
            NSLog(@"lon_num = %f",[lon_1_num floatValue]);
            NSLog(@"abs a: %f",fabs([latitude doubleValue] - [lat_1_num floatValue]));
            NSLog(@"abs b: %f",fabs([longitude doubleValue] - [lon_1_num floatValue]));
            if( ( fabs([latitude doubleValue] - [lat_1_num floatValue]) ) > 0.00001 || ( fabs([longitude doubleValue] - [lon_1_num floatValue] )) > 0.00001){
                isSamePoint = YES;
                CLLocation *originalLoc = [[CLLocation alloc] initWithLatitude:[lat_1_num doubleValue] longitude:[lon_1_num doubleValue]] ;
                [array addObject:originalLoc];
                [array2 addObject:lat_1_num];
                [array3 addObject:lon_1_num];
//                NSLog(@"Here!");
            }
        }
        if (!isSamePoint) {
            [array addObject:loc];
            [array2 addObject:latitude];
            [array3 addObject:longitude];
            }
        
	}

	for(int i = 1; i < array2.count; i++){
        // calculate distance between them
        CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:[[array2 objectAtIndex:i-1] floatValue] longitude:[[array3 objectAtIndex:i-1] floatValue]] ;
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:[[array2 objectAtIndex:i] floatValue] longitude:[[array3 objectAtIndex:i] floatValue]] ;
        CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
        NSLog(@"meters between [%f,%f] and [%f, %f] is %f",[[array2 objectAtIndex:i-1] floatValue],[[array3 objectAtIndex:i-1] floatValue], [[array2 objectAtIndex:i] floatValue],[[array3 objectAtIndex:i] floatValue],meters );
        if ( 1 == i )
            nextmeters = meters;
        //        NSLog(@"i=%@",[array2 objectAtIndex:i]);
        
        // // 計算方位角,正北向為0度，以順時針方向遞增

//        double d = 0;
//        float lat_a_array2 = [[ array2 objectAtIndex:i-1] floatValue];
//        float lng_a_array3 = [[ array3 objectAtIndex:i-1] floatValue];
//        float lat_b_array2 = [[ array2 objectAtIndex:i] floatValue];
//        float lng_b_array3 = [[ array3 objectAtIndex:i] floatValue];
//
//        float lat_a=lat_a_array2*M_PI/180;
//        float lng_a=lng_a_array3*M_PI/180;
//        float lat_b=lat_b_array2*M_PI/180;
//        float lng_b=lng_b_array3*M_PI/180;
//            
//        d=sin(lat_a)*sin(lat_b)+cos(lat_a)*cos(lat_b)*cos(lng_b-lng_a);
//        d=sqrt(1-d*d);
//        d=cos(lat_b)*sin(lng_b-lng_a)/d;
//        d=asin(d)*180/M_PI;
        
            //     d = Math.round(d*10000);
        
        if (meters != 0){
            turn++;
            totalmeters = totalmeters + meters;
//            NSLog(@"angles of [%f, %f] and [%f, %f] = %f",lat_a_array2,lng_a_array3,lat_b_array2,lng_b_array3,result);
//            NSLog(@"angles of [%f, %f] and [%f, %f] = %f",lat1,lon1,lat2,lon2,result);
            NSLog(@"meters=%f",meters);
            
        }
    }
    
    NSLog(@"total turn=%d",turn);
    NSString *mo;
    if (totalmeters > 1000){
        float totalkm = totalmeters / 1000;
        mo = [NSString stringWithFormat:@"總距離：%.3f 公里",totalkm];
    } else {
        mo = [NSString stringWithFormat:@"總距離：%.1f 公尺",totalmeters];
    }
    Distance.shadowColor = [UIColor blackColor];
    Distance.shadowOffset = CGSizeMake(0, -1.0);
    self.Distance.text = mo;
	return array;
}


-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    //    CLLocationCoordinate2D currentLocation = [self getCurrentLocation];  // Use to get current location
    //Or @"http://maps.google.com/maps?saddr=Current+Location&daddr=%@", it need to localize the Current+Location string.
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    NSString* lan_1 = [NSString stringWithFormat:@"%f", f.latitude];
    NSString* lon_1 = [NSString stringWithFormat:@"%f", f.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@&dirflg=w", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	NSLog(@"api url: %@", apiUrl);
    
    NSError *error = nil;
    NSStringEncoding encoding = NSASCIIStringEncoding;
//    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error]; // deprecated.

    NSString *apiResponse = [[NSString alloc ]initWithContentsOfURL:apiUrl encoding:encoding error:&error];
    NSLog(@"error: %@", error);
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
	return [self decodePolyLine:[encodedPoints mutableCopy] lat_1:lan_1 lon_1:lon_1];
}

-(void) centerMap {
    if (routes.count == 0) return;
	MKCoordinateRegion region;

	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;

	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
        
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
        
        
	}


//    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:minLat longitude:minLon];
//    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:maxLat longitude:maxLon];
//    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];

    region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = (maxLat - minLat) * 2;
   
    
    region.span.longitudeDelta = ( maxLon - minLon ) * 2;
     NSLog(@"region.span.latitudeDelta = %f",region.span.latitudeDelta);
     NSLog(@"region.span.longitudeDelta = %f",region.span.longitudeDelta);
//    region.span.latitudeDelta  = maxLat - minLat;
//    region.span.longitudeDelta = maxLon - minLon;
//    region.span.latitudeDelta = meters / 111319.5;
//    region.span.longitudeDelta = 0.0;

	
	[_mapView setRegion:region animated:YES];
}

-(void) showRouteFrom: (Place*) f to:(Place*) t {
	
	if(routes) {
		[_mapView removeAnnotations:[_mapView annotations]];
	}
	
	//PlaceMark* from = [[PlaceMark alloc] initWithPlace:f];
	//PlaceMark* to = [[PlaceMark alloc] initWithPlace:t];

    
    [self addPlacemark:f.latitude longitude:f.longitude title:f.name subTitle:f.description status:STATUS_GOING];
    [self addPlacemark:t.latitude longitude:t.longitude title:t.name subTitle:t.description status:STATUS_GOING];

    CLLocationCoordinate2D coordinae2D_f;
    coordinae2D_f.latitude = f.latitude;
    coordinae2D_f.longitude = f.longitude;
    
    CLLocationCoordinate2D coordinae2D_t;
    coordinae2D_t.latitude = t.latitude;
    coordinae2D_t.longitude = t.longitude;
    
	routes = [self calculateRoutesFrom:coordinae2D_f to:coordinae2D_t];
	[self updateRouteView];
	[self centerMap];
    

}

-(void) updateRouteView {
    if (routes.count == 0){
        /*
        UIAlertView *av=[[UIAlertView alloc]initWithTitle:@"Message" message:@"沒有可到達的路徑" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        */
         routeView.image = nil;
        return;
    }
    CGContextRef context = 	CGBitmapContextCreate(nil,
												  routeView.frame.size.width,
												  routeView.frame.size.height,
												  8,
												  4 * routeView.frame.size.width,
												  CGColorSpaceCreateDeviceRGB(),
												  kCGImageAlphaPremultipliedLast);
	
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 3.0);
	
	for(int i = 0; i < routes.count; i++) {
		CLLocation* location = [routes objectAtIndex:i];
		CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:routeView];
		
		if(i == 0) {
			CGContextMoveToPoint(context, point.x, routeView.frame.size.height - point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, routeView.frame.size.height - point.y);
		}
	}
	
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
	
	routeView.image = img;
	CGContextRelease(context);
    
}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self updateRouteView];
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}

#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (_startingPoint == nil)
        self.startingPoint = newLocation;
    
    currentLatitude = newLocation.coordinate.latitude;
    currentLongitude = newLocation.coordinate.longitude;
    NSLog(@"current Latitude:%f",currentLatitude);
    NSLog(@"current Longitude:%f",currentLongitude);
    //    [_mapView.layer addSublayer:pulseLayer_];
    
    Place* from = [[Place alloc] init];
    from.name = @"Jessica";
    from.description = @"趕路中(預計15分鐘)";
    if ([CLLocationManager headingAvailable]){
       	from.latitude = 25.047292;
        from.longitude = 121.516264;
        
    } else {
        from.latitude = 25.043119;
        from.longitude = 121.509529;
    }
    
    
	Place* to = [[Place alloc] init];
    to.name = @"Miniko";
    to.description = @"目的地";
	to.latitude = 25.049272;
	to.longitude = 121.516879;
    
    [self showRouteFrom:from to:to];
    
    //Show Angle of next point

    CLLocation* nextLocation = [routes objectAtIndex:0];
    float result = [self computeAzimuth:from.latitude lon1:from.longitude lat2:nextLocation.coordinate.latitude lon2:nextLocation.coordinate.longitude];
    NSLog(@"Angle of [%f,%f] [%f,%f] = %f",from.latitude, from.longitude, nextLocation.coordinate.latitude, nextLocation.coordinate.longitude,  result);
    
    
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    NSLog(@"toRad(result) = %f", toRad(result));
    
    NSLog(@"CurrendHeading = %f", toRad(currentHeading));
    
    spin.toValue = [NSNumber numberWithFloat:toRad((CGFloat)-toRad(result)) ]; // This is temp solution for angle;
    spin.duration = 1.f;
    spin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    spin.fillMode=kCAFillModeForwards;
    spin.removedOnCompletion=NO;
    
    
    [CATransaction begin];
    [pulseLayer_ addAnimation:spin forKey:@"spinTheText"];
    [CATransaction commit];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    NSLog(@"Error: %@",errorType);
}


- (void)locationManager:(CLLocationManager*)manager
       didUpdateHeading:(CLHeading*)newHeading
{
    // If the accuracy is valid, process the event.
    if (newHeading.headingAccuracy > 0)
    {
        //取得角度值-磁北(0-北, 90-東, 180-南, 270-西)
        //CLLocationDirection theHeading = newHeading.magneticHeading;
        //取得角度值-正北(0-北, 90-東, 180-南, 270-西)
        CLLocationDirection theHeading = newHeading.trueHeading;
        
        // Do something with the event data.
        
        NSLog(@"%f", theHeading);
        currentHeading = newHeading.trueHeading;
        [self updateHeadingDisplays:theHeading];

    } else {
        NSLog(@"需校正");
    }
    
}
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}

- (void)updateHeadingDisplays:(CLLocationDirection) theHeading {
//    // Animate Compass
    CGRect rect;
    rect.size = CGSizeMake(500, 600);
    [self.mapView setBounds:rect];
    [UIView     animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGAffineTransform headingRotation;
                             headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-toRad(theHeading));
                             _mapView.transform = headingRotation;
                             [_mapView.layer addSublayer:pulseLayer_];
                             
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    
//    NSLog(@"height:%f, width:%f", self.mapView.bounds.size.height, self.mapView.bounds.size.width);
//    [self.mapView setBounds:rect];
    
    
}




#pragma mark - initialization & cleaning up
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray
{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        
//        _menusArray = [aMenusArray copy];
//        
//        // add the menu buttons
//        int count = [_menusArray count];
//        for (int i = 0; i < count; i ++)
//        {
//            QuadCurveMenuItem *item = [_menusArray objectAtIndex:i];
//            item.tag = 1000 + i;
//            item.startPoint = STARTPOINT;
//            item.endPoint = CGPointMake(STARTPOINT.x + ENDRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - ENDRADIUS * cosf(i * M_PI_2 / (count - 1)));
//            item.nearPoint = CGPointMake(STARTPOINT.x + NEARRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - NEARRADIUS * cosf(i * M_PI_2 / (count - 1)));
//            item.farPoint = CGPointMake(STARTPOINT.x + FARRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - FARRADIUS * cosf(i * M_PI_2 / (count - 1)));
//            item.center = item.startPoint;
//            item.delegate = self;
//            [self addSubview:item];
//        }
//        
//        // add the "Add" Button.
//        _addButton = [[QuadCurveMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
//                                             highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"]
//                                                 ContentImage:[UIImage imageNamed:@"icon-plus.png"]
//                                      highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
//        _addButton.delegate = self;
//        _addButton.center = STARTPOINT;
//        [self addSubview:_addButton];
//    }
    return self;
}

- (void)dealloc
{

//    [super dealloc];
}


#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding)
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(_addButton.frame, point);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.expanding = !self.isExpanding;
    UITouch *touch = [touches anyObject];
    
    if(touch.view.tag == 20){
        NSString *mo;
        NSLog(@"isNext = %d",isNext);
        if (isNext) {  // 下一站距離
            Distance.shadowColor = [UIColor blackColor];
            Distance.shadowOffset = CGSizeMake(0, -1.0);
            self.Distance.textColor = [UIColor purpleColor];
            if (nextmeters > 1000){
                float nextkm = nextmeters / 1000;
                mo = [NSString stringWithFormat:@"下一站距離：%.3f 公里",nextkm];
            } else {
                mo = [NSString stringWithFormat:@"下一站距離：%.1f 公尺",nextmeters];
            }
            self.Distance.text = mo;
            isNext = 0;

        } else { // 總距離
            Distance.shadowColor = [UIColor blackColor];
            Distance.shadowOffset = CGSizeMake(0, -1.0);
            self.Distance.textColor = [UIColor redColor];
            if (totalmeters > 1000){
                float totalkm = totalmeters / 1000;
                mo = [NSString stringWithFormat:@"總距離：%.3f 公里",totalkm];
            } else {
                mo = [NSString stringWithFormat:@"總距離：%.1f 公尺",totalmeters];
            }
            self.Distance.text = mo;
            isNext = 1;
        }
    }
}

#pragma mark - QuadCurveMenuItem delegates
- (void)quadCurveMenuItemTouchesBegan:(QuadCurveMenuItem *)item
{
    if (item == _addButton)
    {
        self.expanding = !self.isExpanding;
    }
}
- (void)quadCurveMenuItemTouchesEnd:(QuadCurveMenuItem *)item
{
    // exclude the "add" button
    if (item == _addButton)
    {
        return;
    }
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++)
    {
        QuadCurveMenuItem *otherItem = [_menusArray objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];
        
        otherItem.center = otherItem.startPoint;
    }
    _expanding = NO;
    
    // rotate "add" button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    if ([_delegate respondsToSelector:@selector(quadCurveMenu:didSelectIndex:)])
    {
        [_delegate quadCurveMenu:self didSelectIndex:item.tag - 1000];
    }
}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{
    if (aMenusArray == _menusArray)
    {
        return;
    }

    _menusArray = [aMenusArray copy];
    
    
    // clean subviews
    for (UIView *v in _mapView.subviews)
    {
        if (v.tag >= 1000)
        {
            [v removeFromSuperview];
        }
    }
    // add the menu buttons
    int count = [_menusArray count];
    for (int i = 0; i < count; i ++)
    {
        QuadCurveMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = STARTPOINT;
        item.endPoint = CGPointMake(STARTPOINT.x + ENDRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - ENDRADIUS * cosf(i * M_PI_2 / (count - 1)));
        item.nearPoint = CGPointMake(STARTPOINT.x + NEARRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - NEARRADIUS * cosf(i * M_PI_2 / (count - 1)));
        item.farPoint = CGPointMake(STARTPOINT.x + FARRADIUS * sinf(i * M_PI_2 / (count - 1)), STARTPOINT.y - FARRADIUS * cosf(i * M_PI_2 / (count - 1)));
        item.center = item.startPoint;
        item.delegate = self;
        [_mapView addSubview:item];
    }
}
- (BOOL)isExpanding
{
    return _expanding;
}
- (void)setExpanding:(BOOL)expanding
{
    _expanding = expanding;
    
    // rotate add button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    // expand or close animation
    if (!_timer)
    {
        _flag = self.isExpanding ? 0 : 5;
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMEOFFSET target:self selector:selector userInfo:nil repeats:YES] ;
    }
}
#pragma mark - private methods
- (void)_expand
{
    if (_flag == 6)
    {
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    QuadCurveMenuItem *item = (QuadCurveMenuItem *)[_mapView viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:M_PI],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3],
                                [NSNumber numberWithFloat:.4], nil];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y);
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    _flag ++;
    
}

- (void)_close
{
    if (_flag == -1)
    {
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    QuadCurveMenuItem *item = (QuadCurveMenuItem *)[_mapView viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI * 2],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0],
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;
    _flag --;
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

- (void)quadCurveMenu:(EventMapViewController *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"Select the index : %d",idx);
}

#pragma mark -
#pragma mark ATMHudDelegate
- (void)userDidTapHud:(ATMHud *)_hud {
	[_hud hide];
}

// Uncomment this method to see a demonstration of playing a sound everytime a HUD appears.
/*
 - (void)hudDidAppear:(ATMHud *)_hud {
 NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"pop"
 ofType: @"wav"];
 [hud playSound:soundFilePath];
 }
 */


@end



