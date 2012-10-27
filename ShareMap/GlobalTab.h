


@interface singletonObj : NSObject


@property(nonatomic, strong) NSString * gblStr;

+(singletonObj *)singleObj;

@end