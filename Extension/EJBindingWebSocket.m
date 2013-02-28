
#import "EJBindingWebSocket.h"


@implementation EJBindingWebSocket

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {

    app=[EJApp instance];
    
    return self;

}

// for the New Ejecta
- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    return [self initWithContext:ctxp object:nil argc:argc argv:argv];
    
}


- (void)dealloc {
    // TODO
    [webSocket release];
	[super dealloc];
}





@end