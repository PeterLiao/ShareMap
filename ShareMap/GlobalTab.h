


@interface singletonObj : NSObject


@property(nonatomic, strong) NSString * gblStr;
@property(nonatomic, readwrite) double eventLatitude;
@property(nonatomic, readwrite) double eventLongitude;
@property(nonatomic, strong) NSString * eventTitle;
@property(nonatomic, strong) NSString * eventLocationName;


+(singletonObj *)singleObj;

@end