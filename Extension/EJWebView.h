
#import <UIKit/UIKit.h>
#import "JavaScriptCore/JavaScriptCore.h"

@interface EJWebView : UIWebView<UIWebViewDelegate> {
	
}

@property (nonatomic,assign) BOOL loaded;

- (BOOL)load:(NSString *)path;
- (JSValueRef)evalEjectaJS:(NSString *)script;

@end