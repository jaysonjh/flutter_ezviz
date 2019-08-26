#import "FlutterEzvizPlugin.h"
#import <flutter_ezviz/flutter_ezviz-Swift.h>

@implementation FlutterEzvizPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    EzvizViewFactory *ezvizViewFactory = [[EzvizViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:ezvizViewFactory withId:@"flutter_ezviz_player"];
    [SwiftFlutterEzvizPlugin registerWithRegistrar:registrar];
}
@end
