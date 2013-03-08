
#import "EJBindingEventedBase.h"
#import <SocketRocket/SRWebSocket.h>

typedef enum {
	kEJWebSocketBinaryTypeBlob,
	kEJWebSocketBinaryTypeArrayBuffer
} EJWebSocketBinaryType;

typedef enum {
	kEJWebSocketReadyStateConnecting = 0,
	kEJWebSocketReadyStateOpen = 1,
	kEJWebSocketReadyStateClosing = 2,
	kEJWebSocketReadyStateClosed = 3
} EJWebSocketReadyState;


@interface EJBindingWebSocket : EJBindingEventedBase <SRWebSocketDelegate> 
{

    EJApp *app;
    JSContextRef jsGlobalContext;
   	NSString *url;
    
    EJWebSocketBinaryType binaryType;
	EJWebSocketReadyState readyState;

	SRWebSocket *socket;
	JSObjectRef jsEvent;
	JSStringRef jsDataName;
    JSStringRef jsTargetName;
    JSStringRef jsMessageName;
}


@end