#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContextTexture.h"
#import "EJCanvasContextScreen.h"
#import "EJTexture.h"
#import "EJDrawable.h"


static const char * EJScalingModeNames[] = {
	[kEJScalingModeNone] = "none",
	[kEJScalingModeFitWidth] = "fit-width",
	[kEJScalingModeFitHeight] = "fit-height"
};


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
