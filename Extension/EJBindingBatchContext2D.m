
#import "EJBindingBatchContext2D.h"
#import "EJDrawable.h"

@implementation EJBindingBatchContext2D


- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
        
        app=[EJApp instance];

    }
    return self;
}

// for the New Ejecta
- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    return [self initWithContext:ctxp object:nil argc:argc argv:argv];
    
}

EJ_BIND_FUNCTION(drawImageBatch, ctx, argc, argv) {
    
    EJBindingCanvasContext2D * context = (EJBindingCanvasContext2D *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    EJCanvasContext *renderingContext=context.renderingContext;

    for (int i=1;i<argc;){
        
        NSObject<EJDrawable> * drawable =
        (NSObject<EJDrawable> *)JSObjectGetPrivate((JSObjectRef)argv[i++]);
        
        EJTexture * image = drawable.texture;
        
        float scale = image.contentScale;
        
        short sx = 0, sy = 0, sw = 0, sh = 0;
        float dx = 0, dy = 0, dw = sw, dh = sh;
        
		sx = JSValueToNumberFast(ctx, argv[i++]) * scale;
		sy = JSValueToNumberFast(ctx, argv[i++]) * scale;
		sw = JSValueToNumberFast(ctx, argv[i++]) * scale;
		sh = JSValueToNumberFast(ctx, argv[i++]) * scale;
		
		dx = JSValueToNumberFast(ctx, argv[i++]);
		dy = JSValueToNumberFast(ctx, argv[i++]);
		dw = JSValueToNumberFast(ctx, argv[i++]);
		dh = JSValueToNumberFast(ctx, argv[i++]);

        [renderingContext drawImage:image sx:sx sy:sy sw:sw sh:sh dx:dx dy:dy dw:dw dh:dh];
        
    }
    
    return NULL;
}

EJ_BIND_FUNCTION( strokeLines, ctx, argc, argv ) {
    
    EJBindingCanvasContext2D * context = (EJBindingCanvasContext2D *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    EJCanvasContext *renderingContext=context.renderingContext;
    app.currentRenderingContext = renderingContext;

    float x=0,y=0;
    for (int i=1;i<argc;){
        
        x = JSValueToNumberFast(ctx, argv[i++]);
        y = JSValueToNumberFast(ctx, argv[i++]);
        [renderingContext moveToX:x y:y];
        
        x = JSValueToNumberFast(ctx, argv[i++]);
        y = JSValueToNumberFast(ctx, argv[i++]);
        [renderingContext lineToX:x y:y];
        
    }
    
	return NULL;
}


EJ_BIND_FUNCTION( strokePolyline, ctx, argc, argv ) {
    
    EJBindingCanvasContext2D * context = (EJBindingCanvasContext2D *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    EJCanvasContext *renderingContext=context.renderingContext;
    app.currentRenderingContext = renderingContext;
    
    
    float x = JSValueToNumberFast(ctx, argv[1]),
          y = JSValueToNumberFast(ctx, argv[2]);
    [renderingContext moveToX:x y:y];
    
    for (int i=3;i<argc;){
        x = JSValueToNumberFast(ctx, argv[i++]);
        y = JSValueToNumberFast(ctx, argv[i++]);
        [renderingContext lineToX:x y:y];
        
    }
    
	return NULL;
}

@end
