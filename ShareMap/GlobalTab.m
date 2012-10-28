#import "GlobalTab.h"

@implementation singletonObj
@synthesize gblStr;
@synthesize eventLatitude;
@synthesize eventLongitude;
@synthesize eventTitle;
@synthesize eventLocationName;

+(singletonObj *)singleObj{
    
    static singletonObj * single=nil;
    
    @synchronized(self)
    {
        if(!single)
        {
            single = [[singletonObj alloc] init];
            
        }
        
    }
    return single;
}
@end