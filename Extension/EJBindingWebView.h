
#import "EJBindingBase.h"
#import "EJWebView.h"

@interface EJBindingWebView: EJBindingBase {
    
    short width, height;
    short left, top;
    NSString *src;
    BOOL loading;
    EJWebView *webView;
    
}

- (void)reload;
- (NSString *)eval:(NSString *)script;

@end