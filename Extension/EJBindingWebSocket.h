
#import "EJBindingEventedBase.h"
#import <SocketRocket/SRWebSocket.h>

const unsigned short CONNECTING = 0;
const unsigned short OPEN = 1;
const unsigned short CLOSING = 2;
const unsigned short CLOSED = 3;

@interface EJBindingWebSocket : EJBindingEventedBase <SRWebSocketDelegate> 
{

    unsigned short readyState;
    unsigned long bufferedAmount;
    NSString *url;
    NSString *protocol;
    EJApp *app;
    JSContextRef jsGlobalContext;
    SRWebSocket *_socket;
    
    JSValueRef jsCONNECTING;
    JSValueRef jsOPEN;
    JSValueRef jsCLOSING;
    JSValueRef jsCLOSED;
    
    JSStringRef jsEventData;
    JSStringRef jsEventTarget;
    JSStringRef jsEventMessage;
}


@end