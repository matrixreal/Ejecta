
#import "EJBindingEventedBase.h"
#import "EJWebSocket.h"


@interface EJBindingWebSocket : EJBindingEventedBase  {
    
    EJWebSocket *webSocket;
    EJApp *app;
    
}


@end