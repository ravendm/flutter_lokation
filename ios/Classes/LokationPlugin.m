#import "LokationPlugin.h"
#if __has_include(<lokation/lokation-Swift.h>)
#import <lokation/lokation-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "lokation-Swift.h"
#endif

@implementation LokationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLokationPlugin registerWithRegistrar:registrar];
}
@end
