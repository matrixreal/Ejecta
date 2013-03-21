
#import "JavaScriptCore/JavaScriptCore.h"
#import "EJBindingBase.h"
#import <UIKit/UIKit.h>

@interface EJBindingTimer : EJBindingBase
{
    EJApp *app;
    int uniqueId;
    NSMutableDictionary * timers;
	NSDate * pauseTime;
	NSMutableDictionary * timerTimes;

}


@end
