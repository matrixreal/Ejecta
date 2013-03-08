#import "EJCanvasContext.h"
#import "EAGLView.h"

typedef enum {
	kEJScalingModeNone,
	kEJScalingModeFit,
	kEJScalingModeZoom,
	// TODO: implement a scaling mode that doesn't preserve aspect ratio
	// and just stretches; needs support for touch input as well
} EJScalingMode;




@interface EJCanvasContextScreen : EJCanvasContext {
	EAGLView * glview;
	GLuint colorRenderbuffer;
	
	BOOL useRetinaResolution;
	UIDeviceOrientation orientation;
	EJScalingMode scalingMode;
}

- (void)present;
- (void)finish;

@property (nonatomic) BOOL useRetinaResolution;
@property (nonatomic) EJScalingMode scalingMode;

@end
