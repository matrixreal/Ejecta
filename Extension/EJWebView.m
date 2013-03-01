
#import "EJWebView.h"
#import "EJApp.h"

@implementation EJWebView

@synthesize loaded;

- (id)initWithFrame:(CGRect)frame{
    [super initWithFrame:frame];
    
    app=[EJApp instance];
    self.opaque=NO;
    self.backgroundColor=[UIColor clearColor];
    self.delegate=self;
    
    return self;
}


-(JSValueRef)evalEjectaJS:(NSString *)script {
    
    NSLog(@"scriptJS : %@",script);
    
    JSGlobalContextRef jsGlobalContext=[app jsGlobalContext];
    
    JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
    JSValueRef exception = NULL;
    
    
	JSValueRef result=JSEvaluateScript( jsGlobalContext, scriptJS, NULL, NULL, 0, &exception );
	[app logException:exception ctx:jsGlobalContext];
    
    // JSType type=JSValueGetType(jsGlobalContext,result);
    
    JSStringRelease( scriptJS );
    
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    loaded=YES;
      NSString *script=@"window._webviewId=Date.now();window._webviewHasLoaded=true; ";
   [webView stringByEvaluatingJavaScriptFromString:script];
    
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *urlString = url.absoluteString;
    NSRange range = [urlString rangeOfString:@"exec://"];    
    if ( range.length > 0 && range.location==0 ) {
        NSString *script = [urlString substringFromIndex:range.length];
//        NSLog(@"script : %@",script);
        [self evalEjectaJS:script];
        return NO;
    } else {
        return YES;
    }

}

- (void)loadRequest:(NSURLRequest *)request {
    loaded=NO;
    [super loadRequest:request];
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
    
    [self loadRequest:appReq];
    while (self.loading){
        [NSThread sleepForTimeInterval:9.0f];
    }
    return YES;
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

- (void)dealloc {
	// TODO
    // 
    [super dealloc];
    
}

@end
