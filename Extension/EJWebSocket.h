
#import <UIKit/UIKit.h>
#import "JavaScriptCore/JavaScriptCore.h"
#import "EJApp.h"
#import <SocketRocket/SRWebSocket.h>

@interface EJWebSocket : NSObject {
	EJApp *app;
}

@property (nonatomic,assign) BOOL loaded;


- (void)open;
- (void)close;
- (void)send:(NSString *)data;

@end