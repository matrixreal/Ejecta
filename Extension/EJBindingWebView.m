
#import "EJBindingWebView.h"


@implementation EJBindingWebView

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    app=[EJApp instance];
    
    CGSize screen = app.view.bounds.size;
    width = screen.width;
    height = screen.height;
    left = 0;
    top =0;
    CGRect webViewBounds=CGRectMake(left,top,width,height);
    webView=[[EJWebView alloc] initWithFrame:webViewBounds];
    [app.view addSubview: webView];
    
    //[webView eval: @"console.log('test eval')"];
    
    return self;
    
}

// for the New Ejecta
- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    return [self initWithContext:ctxp object:nil argc:argc argv:argv];
    
}



- (void)load {
    [webView load:src];
}


- (void)reload{
    [webView reload];
};



-(NSString *)eval:(NSString *)script {
    NSString *result=[webView stringByEvaluatingJavaScriptFromString:script];
    return result;
}

- (void)dealloc {
	// TODO 
    [src release];
    [webView release];
	[super dealloc];
}


EJ_BIND_FUNCTION( eval, ctx, argc, argv ) {
    NSString *script = JSValueToNSString(ctx, argv[0]);
    
    NSLog(@"script : %@", script);
    NSString *result = [self eval:script];
    
    JSStringRef _result = JSStringCreateWithUTF8CString( [result UTF8String] );
    //	JSStringRelease(_result);
    return JSValueMakeString(ctx, _result);
    
}

EJ_BIND_FUNCTION( isLoaded, ctx, argc, argv ) {
    if ([[self eval:@"document.readyState==='complete'"] isEqualToString:@"true"]){
        return JSValueMakeBoolean(ctx, true);
    }
    return JSValueMakeBoolean(ctx, false);
}

EJ_BIND_FUNCTION( reload, ctx, argc, argv ) {
    [self reload];
    return NULL;
}


EJ_BIND_GET(loading, ctx) {
	return JSValueMakeBoolean(ctx, loading);
}
EJ_BIND_GET(loaded, ctx) {
	return JSValueMakeBoolean(ctx, [webView loaded]);
}

EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, width);
}

EJ_BIND_SET(width, ctx, value) {
	width = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(height, ctx) {
	return JSValueMakeNumber(ctx, height);
}

EJ_BIND_SET(height, ctx, value) {
	height = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(left, ctx) {
	return JSValueMakeNumber(ctx, left);
}

EJ_BIND_SET(left, ctx, value) {
	left = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(top, ctx) {
	return JSValueMakeNumber(ctx, top);
}

EJ_BIND_SET(top, ctx, value) {
	top = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(src, ctx ) {
	JSStringRef _src = JSStringCreateWithUTF8CString( [src UTF8String] );
	JSValueRef ret = JSValueMakeString(ctx, _src);
	JSStringRelease(_src);
	return ret;
}

EJ_BIND_SET(src, ctx, value) {
	
    if( loading ) { return; }
	
	NSString * newSrc = JSValueToNSString( ctx, value );
    
	// Release the old path and texture?
	if( src ) {
		[src release];
		src = nil;
		
    }
	
	if( [newSrc length] ) {
		src = [newSrc retain];
	}else{
        src = @"about:blank";
    }
    [self load];
}


@end