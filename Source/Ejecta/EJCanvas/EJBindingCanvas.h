#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"
#import "EJCanvasContextScreen.h"


@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
    JSObjectRef jsCanvasContext;
	EJCanvasContext * renderingContext;
	EJApp * ejectaInstance;
	short width, height;
	
	BOOL isScreenCanvas;
	BOOL useRetinaResolution;
	EJScalingMode scalingMode;
	
	BOOL msaaEnabled;
	int msaaSamples;
}
	
@property (readonly, nonatomic) EJTexture * texture;

@end
