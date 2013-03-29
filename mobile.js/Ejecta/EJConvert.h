#import <Foundation/Foundation.h>
#import "JavaScriptCore/JavaScriptCore.h"
#import "MJSExceptions.h"


#ifdef __cplusplus
extern "C" {
#endif

NSString *JSValueToNSString( JSContextRef ctx, JSValueRef v );
JSValueRef NSStringToJSValue( JSContextRef ctx, NSString *string );
JSValueRef NSStringToJSValueProtect( JSContextRef ctx, NSString *string );
double JSValueToNumberFast( JSContextRef ctx, JSValueRef v );
void JSValueUnprotectSafe( JSContextRef ctx, JSValueRef v );

JSValueRef NSExceptionToJSValue( JSContextRef ctx, NSException *e );
JSValueRef NSErrorToJSValue( JSContextRef ctx, NSError *e );

JSValueRef JSMakeError(JSContextRef ctx, NSString *message);
JSValueRef JSMakeErrorWithType(JSContextRef ctx, NSString *message, NSString *type);

UIColor *JSValueToUIColor(JSContextRef ctx, JSValueRef v);
JSValueRef UIColorToJSValue(JSContextRef ctx, UIColor *color);

#ifdef __cplusplus
}
#endif