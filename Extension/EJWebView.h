
#import <UIKit/UIKit.h>
#import "JavaScriptCore/JavaScriptCore.h"
#import "EJApp.h"

@interface EJWebView : UIWebView<UIWebViewDelegate> {
	EJApp *app;
}

@property (nonatomic,assign) BOOL loaded;

- (BOOL)load:(NSString *)path;
- (JSValueRef)evalEjectaJS:(NSString *)script;
- (NSString *) dictionaryToJSONString:(NSDictionary *)dictionary;


@end