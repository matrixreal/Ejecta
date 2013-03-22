
#import "EJBindingWebView.h"
#import "OpenUDID.h"

@implementation EJBindingWebView 

@synthesize loaded;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
  
    if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {

    app=[EJApp instance];
    
    CGSize screen = app.view.bounds.size;
    width = screen.width;
    height = screen.height;
    NSLog(@"size %d %d",width,height);
    
    left = 0;
    top =0;
    CGRect webViewBounds=CGRectMake(left,top,width,height);
    webView=[[UIWebView alloc] initWithFrame:webViewBounds];
    webView.mediaPlaybackRequiresUserAction=NO;
    webView.opaque=NO;
    webView.backgroundColor=[UIColor clearColor];
    webView.delegate=self;
    [app.view addSubview: webView];
    
    //[webView eval: @"console.log('test eval')"];
    
    }
    return self;
    
}

// for the New Ejecta
- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    return [self initWithContext:ctxp object:nil argc:argc argv:argv];
    
}


-(NSString *)evalScriptInWeb:(NSString *)script {
    NSString *result=[webView stringByEvaluatingJavaScriptFromString:script];
    return result;
}

-(JSValueRef)evalScriptInNative:(NSString *)script {
    
    
    JSGlobalContextRef jsGlobalContext=[app jsGlobalContext];
    
    JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
    JSValueRef exception = NULL;
    
    
	JSValueRef result=JSEvaluateScript( jsGlobalContext, scriptJS, NULL, NULL, 0, &exception );
	[app logException:exception ctx:jsGlobalContext];
    
    // JSType type=JSValueGetType(jsGlobalContext,result);
    
    JSStringRelease( scriptJS );
    
    return result;
}


- (void)loadRequest:(NSURLRequest *)request {
    loaded=NO;
    [webView loadRequest:request];
}

- (BOOL)load:(NSString *)path {
	
    NSURL* appURL;
    
    if ([path hasPrefix:@"http:"] || [path hasPrefix:@"https:"]){
        appURL=[NSURL URLWithString:path];
        NSLog(@"webview load remote url : %@",appURL);
    }else{
        NSString* startFilePath = [app pathForResource: path];
        appURL = [NSURL fileURLWithPath:startFilePath];
        NSLog(@"webview load local url : %@",appURL);
    }
    
    
    NSURLRequest *appReq = [NSURLRequest requestWithURL:appURL];
    //     NSURLRequest *appReq = [NSURLRequest requestWithURL:appURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.0];
    
    [webView loadRequest:appReq];
    while (webView.loading){
        [NSThread sleepForTimeInterval:2.0f];
    }
    return YES;
}

- (void)reload
{
    [self load:src];
}

-(NSString *) dictionaryToJSONString:(NSDictionary *)dictionary {
    NSError *error;
    NSString *jsonString;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    NSString* openUDID = [OpenUDID value];    
    NSString* script = [NSString stringWithFormat:@"window._webviewId=Date.now();window._webviewHasLoaded=true;window.udid=\"%@\";", openUDID];
    NSLog(@"webview onload : %@", script);
    [_webView stringByEvaluatingJavaScriptFromString:script];
    
}

- (BOOL) webView:(UIWebView*)_webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    
    if ([[url scheme] isEqualToString:@"eval"]){
        
        // scheme://user:password@host:port/path?query#fragment
        
//        NSLog(@"url query: %@",[url query]);
        //        NSLog(@"url fragment: %@",[url fragment]);
//        NSLog(@"url host: %@",[url host]);
        //        NSLog(@"url port: %@",[url port]);
//        NSLog(@"url path: %@",[url path]);
        //        NSLog(@"url absoluteString: %@",[url absoluteString]);
        //        NSLog(@"url relativePath: %@",[url relativePath]);
        //        NSLog(@"url relativeString: %@",[url relativeString]);
        //        NSLog(@"url parameterString: %@",[url parameterString]);
        
        NSString *script = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"evalScriptInNative : %@",script);
        
        [self evalScriptInNative:script];
        return NO;
    } else {
        if ([[url absoluteString] isEqualToString:@"about:blank"]){
            return NO;
        }
        NSLog(@"url: %@",[url absoluteURL]);
        return YES;
    }
    
}



- (void)dealloc {
	// TODO 
    [src release];
    [webView release];
    app=nil;
    
	[super dealloc];
    
}


EJ_BIND_FUNCTION( eval, ctx, argc, argv ) {
    NSString *script = JSValueToNSString(ctx, argv[0]);
    
    NSLog(@"evalScriptInWeb : %@", script);
    NSString *result = [self evalScriptInWeb:script];
    
    JSStringRef _result = JSStringCreateWithUTF8CString( [result UTF8String] );
    //	JSStringRelease(_result);
    return JSValueMakeString(ctx, _result);
    
}

EJ_BIND_FUNCTION( isLoaded, ctx, argc, argv ) {
    if ([[self evalScriptInWeb:@"document.readyState==='complete'"] isEqualToString:@"true"]){
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
	return JSValueMakeBoolean(ctx, [self loaded]);
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
    
	// Release the old path
	if( src ) {
		[src release];
    }
	
	if( [newSrc length] ) {
		src = [newSrc retain];
	}else{
        src = @"about:blank";
    }
    [newSrc release];
    [self load:src];
    
}


@end