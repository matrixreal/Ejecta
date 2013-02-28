
#import "EJWebSocket.h"


@implementation EJWebSocket

@synthesize loaded;

- (id)initWithFrame:(CGRect)frame{
    
    app=[EJApp instance];

    
    return self;
}


- (void)open {
    
}


- (void)close{
    
}

- (void)send:(NSString *)data{
    
}


- (void)dealloc {
	[super dealloc];
}

@end
