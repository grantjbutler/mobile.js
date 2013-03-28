#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class MJSMobileJSController;
@interface EJClassLoader : NSObject

+ (JSClassRef)getJSClass:(id)class;
+ (JSClassRef)createJSClass:(id)class;
+ (JSValueRef)getConstructorOfClass:(id)class controller:(MJSMobileJSController *)controller context:(JSContextRef)ctx;

@end
