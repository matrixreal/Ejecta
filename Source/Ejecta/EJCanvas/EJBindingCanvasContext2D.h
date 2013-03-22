#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContext.h"
#import "EJCanvasContextTexture.h"



@interface EJBindingCanvasContext2D : EJBindingBase {
	JSObjectRef jsCanvas;
	EJCanvasContext * renderingContext;
    EJApp * ejectaInstance;
}

@property (assign, nonatomic) EJCanvasContext * renderingContext;

- (id)initWithCanvas:(JSObjectRef)canvas renderingContext:(EJCanvasContext *)renderingContextp;

@end
