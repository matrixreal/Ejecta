
#import "EJBindingWebSocket.h"



@implementation EJBindingWebSocket

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) { 

        app=[EJApp instance];
        jsGlobalContext = app.jsGlobalContext;
        
        if( argc > 0 ) {
			url = [JSValueToNSString(ctx, argv[0]) retain];
			
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
			socket = [[SRWebSocket alloc] initWithURLRequest:request];
			socket.delegate = self;
			[socket open];
			readyState = kEJWebSocketReadyStateConnecting;
		}
		else {
			url = [@"" retain];
			readyState = kEJWebSocketReadyStateClosed;
		}
		
		// FIXME: we don't support the 'blob' type yet, but the spec dictates this should
		// be the default
		binaryType = kEJWebSocketBinaryTypeBlob;
		
		jsEvent = JSObjectMake(ctx, NULL, NULL);
		JSValueProtect(ctx, jsEvent);
		jsDataName = JSStringCreateWithUTF8CString("data");
        jsTargetName = JSStringCreateWithUTF8CString("target");
        jsMessageName = JSStringCreateWithUTF8CString("message");
        JSObjectSetProperty( jsGlobalContext, jsEvent, jsTargetName, jsObject, kJSPropertyAttributeNone, NULL );
        
    }
    return self;

}

// for the New Ejecta
- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    return [self initWithContext:ctxp object:nil argc:argc argv:argv];
    
}

- (void)prepareGarbageCollection {
	[socket close];
	[socket release];
	socket = nil;
}

- (void)dealloc {
	JSValueUnprotectSafe(app.jsGlobalContext, jsEvent);
	JSStringRelease(jsDataName);
	JSStringRelease(jsTargetName);
    JSStringRelease(jsMessageName);
	[url release];
	[socket release];
    app = nil;
    jsGlobalContext = nil;
    binaryType = nil;
	readyState = nil;
	[super dealloc];
}




- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{    
    // string only
	JSValueRef jsMessage = NSStringToJSValue(jsGlobalContext, message);
	JSObjectSetProperty(jsGlobalContext, jsEvent, jsDataName, jsMessage, kJSPropertyAttributeNone, NULL);
	[self triggerEvent:@"message" argc:1 argv:(JSValueRef[]){ jsEvent }];
    JSObjectDeleteProperty(jsGlobalContext, jsEvent, jsDataName, NULL);

}


- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    readyState = kEJWebSocketReadyStateOpen;

    [self triggerEvent:@"open" argc:1 argv:(JSValueRef[]){ jsEvent } ];
}


- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    
	readyState = kEJWebSocketReadyStateClosed;
    
    JSValueRef jsErrorMessage=NSStringToJSValue(jsGlobalContext, [error localizedDescription]);
    JSObjectSetProperty( jsGlobalContext, jsEvent, jsMessageName, jsErrorMessage, kJSPropertyAttributeNone, NULL );
    [self triggerEvent:@"error" argc:1 argv:(JSValueRef[]){ jsEvent } ];
    JSObjectDeleteProperty(jsGlobalContext, jsEvent, jsMessageName, NULL);
    
    socket.delegate = nil;
    [socket release];
    socket = nil;
}



- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
	
    readyState = kEJWebSocketReadyStateClosed;
    
    [self triggerEvent:@"close" argc:1 argv:(JSValueRef[]){ jsEvent } ];
    
	// Unprotect self from garbage collection
	JSValueUnprotectSafe(app.jsGlobalContext, jsObject);
	
    socket.delegate = nil;
	[socket release];
	socket = nil;
}




EJ_BIND_FUNCTION(send, ctx, argc, argv) {
    if( argc < 1 || readyState != kEJWebSocketReadyStateOpen ) { return NULL; }
    // string 
    [socket send: JSValueToNSString(ctx, argv[0]) ];
    return NULL;
}

EJ_BIND_FUNCTION(close, ctx, argc, argv) {
	if( readyState == kEJWebSocketReadyStateClosing || readyState == kEJWebSocketReadyStateClosed ) {
		return NULL;
	}
	readyState = kEJWebSocketReadyStateClosing;
    [socket close];
    return NULL;
}

EJ_BIND_GET(url, ctx) {
	return NSStringToJSValue(ctx, url);
}

EJ_BIND_GET(readyState, ctx) {
	return JSValueMakeNumber(ctx, readyState);
}

EJ_BIND_GET(bufferedAmount, ctx) {
	// FIXME: SocketRocket doesn't expose this
	return JSValueMakeNumber(ctx, 0);
}

EJ_BIND_GET(extensions, ctx) {
	return NSStringToJSValue(ctx, @"");
}

EJ_BIND_GET(protocol, ctx) {
	return NSStringToJSValue(ctx, @"");
}

EJ_BIND_ENUM(binaryType, binaryType,
     "blob",			// kEJWebSocketBinaryTypeBlob,
     "arraybuffer"	// kEJWebSocketBinaryTypeArrayBuffer
);

EJ_BIND_EVENT(open);
EJ_BIND_EVENT(message);
EJ_BIND_EVENT(error);
EJ_BIND_EVENT(close);

EJ_BIND_CONST(CONNECTING, kEJWebSocketReadyStateConnecting);
EJ_BIND_CONST(OPEN, kEJWebSocketReadyStateOpen);
EJ_BIND_CONST(CLOSING, kEJWebSocketReadyStateClosing);
EJ_BIND_CONST(CLOSED, kEJWebSocketReadyStateClosed);


@end