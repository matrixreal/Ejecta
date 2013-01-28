
#import "EJWebView.h"
#import "EJApp.h"


@implementation EJWebView

@synthesize loaded;

- (id)initWithFrame:(CGRect)frame{
    [super initWithFrame:frame];
    
    self.opaque=NO;
    self.backgroundColor=[UIColor clearColor];
    self.delegate=self;
    
    return self;
}


-(JSValueRef)evalEjectaJS:(NSString *)script {
    
    JSGlobalContextRef jsGlobalContext=[[EJApp instance] jsGlobalContext];
    
    JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
    JSValueRef exception = NULL;
	JSValueRef result=JSEvaluateScript( jsGlobalContext, scriptJS, NULL, NULL, 0, &exception );
	[[EJApp instance] logException:exception ctx:jsGlobalContext];
    
    // JSType type=JSValueGetType(jsGlobalContext,result);
    
    JSStringRelease( scriptJS );
    
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    loaded=YES;
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
	
    NSString* startFilePath = [[EJApp instance] pathForResource: path];
    NSURL* appURL = [NSURL fileURLWithPath:startFilePath];
    NSURLRequest *appReq = [NSURLRequest requestWithURL:appURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.0];
    
    [self loadRequest:appReq];
    while (self.loading){
        [NSThread sleepForTimeInterval:10.0f];
    }
    return YES;
}

- (void)dealloc {
	[super dealloc];
}

@end
