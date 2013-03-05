
#import "EJBindingWebSocket.h"



@implementation EJBindingWebSocket

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) { 
        NSLog(@"EJBindingWebSocket initWithContext");

        jsCONNECTING = JSValueMakeNumber(ctx, CONNECTING );
        jsOPEN = JSValueMakeNumber(ctx, OPEN );
        jsCLOSING = JSValueMakeNumber(ctx, CLOSING );
        jsCLOSED = JSValueMakeNumber(ctx, CLOSED );

        jsEventData = JSStringCreateWithUTF8CString("data");
        jsEventTarget = JSStringCreateWithUTF8CString("target");
        jsEventMessage =  JSStringCreateWithUTF8CString("message");

        app=[EJApp instance];
        jsGlobalContext = app.jsGlobalContext;
        
        url=JSValueToNSString(ctx, argv[0]);
        protocol=JSValueToNSString(ctx, argv[1]);

        [self open];
    }
    return self;

}

// for the New Ejecta
- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    return [self initWithContext:ctxp object:nil argc:argc argv:argv];
    
}


- (void)dealloc {
    // TODO
    [_socket release];
    [protocol release];
    [url release];

    jsCONNECTING = nil;
    jsOPEN = nil;
    jsCLOSING = nil;
    jsCLOSED = nil;
    
    JSStringRelease(jsEventData);
    JSStringRelease(jsEventTarget);
    JSStringRelease(jsEventMessage);
    
    jsEventData = nil;
    jsEventTarget = nil;
    jsEventMessage = nil;
    jsGlobalContext = nil;
    app = nil;
	[super dealloc];
}


- (void)open {
    NSURL *_url=[NSURL URLWithString:url];
    NSLog(@"_url : %@",_url);
    _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:_url ]];
//    _socket = [[SRWebSocket alloc] initWithURL:[NSURLRequest requestWithURL:_url] protocols:nil];
    _socket.delegate = self;
    [_socket open];
}

- (void)close;
{
    [_socket close];
    _socket.delegate = nil;
    _socket = nil;
}

- (void)send:(NSString *)data{
    [_socket send:data];
    //[data release];
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message;
{
   
    JSValueRef jsMessage=NSStringToJSValue(jsGlobalContext, message);
  
    JSObjectRef eventObj = JSObjectMake(jsGlobalContext, NULL, NULL);
    JSObjectSetProperty( jsGlobalContext, eventObj, jsEventTarget, jsObject, kJSPropertyAttributeNone, NULL );
	JSObjectSetProperty( jsGlobalContext, eventObj, jsEventData, jsMessage, kJSPropertyAttributeNone, NULL );

    [self triggerEvent:@"message" argc:1 argv:(JSValueRef[]){ eventObj } ];
    
}


- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    JSObjectRef eventObj = JSObjectMake(jsGlobalContext, NULL, NULL);
    JSObjectSetProperty( jsGlobalContext, eventObj, jsEventTarget, jsObject, kJSPropertyAttributeNone, NULL );
    [self triggerEvent:@"open" argc:1 argv:(JSValueRef[]){ eventObj } ];
}


- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    
    JSValueRef jsErrorMessage=NSStringToJSValue(jsGlobalContext, [error localizedDescription]);
    
    JSObjectRef eventObj = JSObjectMake(jsGlobalContext, NULL, NULL);
    JSObjectSetProperty( jsGlobalContext, eventObj, jsEventTarget, jsObject, kJSPropertyAttributeNone, NULL );
    JSObjectSetProperty( jsGlobalContext, eventObj, jsEventMessage, jsErrorMessage, kJSPropertyAttributeNone, NULL );
    
    [self triggerEvent:@"error" argc:1 argv:(JSValueRef[]){ eventObj } ];
    
    _socket.delegate = nil;
    _socket = nil;
}


- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    
    JSObjectRef eventObj = JSObjectMake(jsGlobalContext, NULL, NULL);
    JSObjectSetProperty( jsGlobalContext, eventObj, jsEventTarget, jsObject, kJSPropertyAttributeNone, NULL );
    [self triggerEvent:@"close" argc:1 argv:(JSValueRef[]){ eventObj } ];
    
    _socket.delegate = nil;
    _socket = nil;
}




EJ_BIND_GET(CONNECTING, ctx) {
	return jsCONNECTING;
}
EJ_BIND_GET(OPEN, ctx) {
	return jsOPEN;
}
EJ_BIND_GET(CLOSING, ctx) {
	return jsCLOSING;
}
EJ_BIND_GET(CLOSED, ctx) {
	return jsCLOSED;
}

EJ_BIND_GET(url, ctx) {
	return NSStringToJSValue( ctx, url );
}

EJ_BIND_GET(protocol, ctx) {
	return NSStringToJSValue( ctx, protocol );
}

EJ_BIND_GET(readyState, ctx) {
    readyState = _socket.readyState;
	return JSValueMakeNumber( ctx, readyState );
}

EJ_BIND_GET(bufferedAmount, ctx) {
	return JSValueMakeNumber( ctx, bufferedAmount );
}


EJ_BIND_EVENT(open);
EJ_BIND_EVENT(message);
EJ_BIND_EVENT(close);
EJ_BIND_EVENT(error);

EJ_BIND_FUNCTION(send, ctx, argc, argv) {
    NSString *stringData = JSValueToNSString(ctx, argv[0]);
    [self send:stringData];
    return NULL;
}

EJ_BIND_FUNCTION(close, ctx, argc, argv) {
    [self close];
    return NULL;
}





@end