
#import "EJBindingApp.h"
#import "OpenUDID.h"

@implementation EJBindingApp



EJ_BIND_GET(udid, ctx) {
    NSString* openUDID = [OpenUDID value];
    return NSStringToJSValue(ctx, openUDID);
}


EJ_BIND_GET(uuid, ctx) {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    static NSString* UUID_KEY = @"EJ_DEV_UUID";
    
    NSString* app_uuid = [userDefaults stringForKey:UUID_KEY];
    
    if (app_uuid == nil) {
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        
        app_uuid = [NSString stringWithString:(NSString*)uuidString];
        [userDefaults setObject:app_uuid forKey:UUID_KEY];
        [userDefaults synchronize];
        
        CFRelease(uuidString);
        CFRelease(uuidRef);
    }
	return NSStringToJSValue(ctx, app_uuid);
}

EJ_BIND_GET(ver, ctx){
    NSString *ver=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return NSStringToJSValue(ctx, ver);
}

@end
