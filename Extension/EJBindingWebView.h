
#import <UIKit/UIKit.h>
#import "JavaScriptCore/JavaScriptCore.h"
#import "EJBindingBase.h"


@interface EJBindingWebView : EJBindingBase <UIWebViewDelegate>  {
    
    short width, height;
    short left, top;
    NSString *src;
    BOOL loading;
    UIWebView *webView;
    EJApp *app;
    
}

@property (nonatomic,assign) BOOL loaded;

- (BOOL)load:(NSString *)path;
- (void)reload;
- (NSString *)evalScriptInWeb:(NSString *)script;
- (JSValueRef)evalScriptInNative:(NSString *)script;
- (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary;

@end