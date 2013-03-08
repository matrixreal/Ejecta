#import "EJBindingCanvas.h"
#import "EJBindingCanvasContext.h"


@implementation EJBindingCanvas

static int firstCanvasInstance = YES;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
	
		ejectaInstance = [EJApp instance]; // Keep a local copy - may be faster?
//		scalingMode = kEJScalingModeFitWidth;
        scalingMode = kEJScalingModeFit;
		useRetinaResolution = true;
		msaaEnabled = false;
		msaaSamples = 2;
		
		// If this is the first canvas instance we created, make it the screen canvas
		if( firstCanvasInstance ) {
			isScreenCanvas = YES;
			firstCanvasInstance = NO;
		}
		
		if( argc == 2 ) {
			width = JSValueToNumberFast(ctx, argv[0]);
			height = JSValueToNumberFast(ctx, argv[1]);
		}
		else {
			CGSize screen = [EJApp instance].view.bounds.size;
			width = screen.width;
			height = screen.height;
		}
	}
	return self;
}

- (void)dealloc {	
	[renderingContext release];
	[super dealloc];
}


EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, width);
}

EJ_BIND_SET(width, ctx, value) {
	short newWidth = JSValueToNumberFast(ctx, value);
	if( renderingContext && newWidth != width ) {
		NSLog(@"Warning: rendering context already created; can't change width");
		return;
	}
	width = newWidth;
}

EJ_BIND_GET(height, ctx) {
	return JSValueMakeNumber(ctx, height);
}

EJ_BIND_SET(height, ctx, value) {
	short newHeight = JSValueToNumberFast(ctx, value);
	if( renderingContext && newHeight != height ) {
		NSLog(@"Warning: rendering context already created; can't change height");
		return;
	}
	height = newHeight;
}

EJ_BIND_GET(offsetLeft, ctx) {
	return JSValueMakeNumber(ctx, 0);
}

EJ_BIND_GET(offsetTop, ctx) {
	return JSValueMakeNumber(ctx, 0);
}



EJ_BIND_SET(retinaResolutionEnabled, ctx, value) {
	useRetinaResolution = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(retinaResolutionEnabled, ctx) {
	return JSValueMakeBoolean(ctx, useRetinaResolution);
}


EJ_BIND_SET(MSAAEnabled, ctx, value) {
	msaaEnabled = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(MSAAEnabled, ctx) {
	return JSValueMakeBoolean(ctx, msaaEnabled);
}

EJ_BIND_SET(MSAASamples, ctx, value) {
	int samples = JSValueToNumberFast(ctx, value);
	if( samples == 2 || samples == 4 ) {
		msaaSamples	= samples;
	}
}

EJ_BIND_GET(MSAASamples, ctx) {
	return JSValueMakeNumber(ctx, msaaSamples);
}

EJ_BIND_ENUM(scalingMode, scalingMode,
             "none",	// kEJScalingModeNone
             "fit",	// kEJScalingModeFit
             "zoom"	// FitHeight
             );

- (EJTexture *)texture {
	if( [renderingContext isKindOfClass:[EJCanvasContextTexture class]] ) {
		return ((EJCanvasContextTexture *)renderingContext).texture;
	}
	else {
		return nil;
	}
}

EJ_BIND_FUNCTION(getContext, ctx, argc, argv) {
	if( argc < 1 || ![JSValueToNSString(ctx, argv[0]) isEqualToString:@"2d"] ) {
		return NULL;
	};
	
	if( renderingContext ) { return jsCanvasContext; }
	ejectaInstance.currentRenderingContext = nil;
    
	if( isScreenCanvas ) {
		EJCanvasContextScreen * sc = [[EJCanvasContextScreen alloc] initWithWidth:width height:height];
		sc.useRetinaResolution = useRetinaResolution;
		sc.scalingMode = scalingMode;
		
		ejectaInstance.screenRenderingContext = sc;
		renderingContext = sc;
	}
	else {
		renderingContext = [[EJCanvasContextTexture alloc] initWithWidth:width height:height];
	}
	
	renderingContext.msaaEnabled = msaaEnabled;
	renderingContext.msaaSamples = msaaSamples;
	
	[renderingContext create];
	ejectaInstance.currentRenderingContext = renderingContext;
    
    // Create the JS object
    EJBindingCanvasContext *binding = [[EJBindingCanvasContext alloc]
                                         initWithCanvas:jsObject renderingContext:(EJCanvasContext *)renderingContext];
    jsCanvasContext = [EJBindingCanvasContext createJSObjectWithContext:ctx instance:binding];
    [binding release];
    JSValueProtect(ctx, jsCanvasContext);
    
	return jsCanvasContext;
}



@end
