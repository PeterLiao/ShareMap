#import "GlobalTab.h"

@implementation singletonObj
@synthesize gblStr;

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