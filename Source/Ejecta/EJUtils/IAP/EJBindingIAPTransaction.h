#import "EJBindingBase.h"
#import <StoreKit/StoreKit.h>

@interface EJBindingIAPTransaction : EJBindingBase {
	SKPaymentTransaction *transaction;
    EJApp *app;
}

- (id)initWithTransaction:(SKPaymentTransaction *)transaction;

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	app:(EJApp *)app
	transaction:(SKPaymentTransaction *)transaction;

@end
