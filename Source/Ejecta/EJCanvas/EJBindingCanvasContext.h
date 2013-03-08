#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContext.h"
#import "EJCanvasContextTexture.h"



@interface EJBindingCanvasContext : EJBindingBase {
	JSObjectRef jsCanvas;
	EJCanvasContext * renderingContext;
    EJApp * ejectaInstance;
}

- (id)initWithCanvas:(JSObjectRef)canvas renderingContext:(EJCanvasContext *)renderingContextp;

@end
