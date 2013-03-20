#import "EJBindingBase.h"
#import <StoreKit/StoreKit.h>

@interface EJBindingIAPProduct : EJBindingBase {
	SKProduct *product;
	JSObjectRef callback;
    
    EJApp *app;
}

- (id)initWithProduct:(SKProduct *)product;
- (void)finishPurchaseWithTransaction:(SKPaymentTransaction *)transaction;

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
    app:(EJApp *)app
	product:(SKProduct *)product;

+ (EJBindingIAPProduct *)bindingFromJSValue:(JSValueRef)value;


@end
