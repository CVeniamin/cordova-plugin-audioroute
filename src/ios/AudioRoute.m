#import "AudioRoute.h"

@implementation AudioRoute

NSString *const kLineOut         = @"line-out";
NSString *const kHeadphones      = @"headphones";
NSString *const kBluetoothA2DP   = @"bluetooth-a2dp";
NSString *const kBuiltinReceiver = @"builtin-receiver";
NSString *const kBuiltinSpeaker  = @"builtin-speaker";
NSString *const kHdmi            = @"hdmi";
NSString *const kAirPlay         = @"airplay";
NSString *const kBluetoothLE     = @"bluetooth-le";
NSString *const kUnknown         = @"unknown";


- (void)pluginInitialize {
    NSLog(@"Initializing AudioRoute plugin");
    callbackId = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(routeChange:)
                                          name:AVAudioSessionRouteChangeNotification
                                          object:nil];
    NSLog(@"AudioRoute plugin initialized");
}


- (void)routeChange:(NSNotification*)notification {
    NSLog(@"Audio device route changed!");
    if (callbackId != nil) {
        CDVPluginResult* pluginResult;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
}


- (void) setRouteChangeCallback:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult;
    callbackId = command.callbackId;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) currentOutputs:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult;
    NSMutableArray* outputs = [NSMutableArray array];

    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        NSString* portType = [desc portType];
        if ([portType isEqualToString:AVAudioSessionPortLineOut]) {
            [outputs addObject:kLineOut];
        } else if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [outputs addObject:kHeadphones];
        } else if ([portType isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
            [outputs addObject:kBluetoothA2DP];
        } else if ([portType isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
            [outputs addObject:kBuiltinReceiver];
        } else if ([portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            [outputs addObject:kBuiltinSpeaker];
        } else if ([portType isEqualToString:AVAudioSessionPortHDMI]) {
            [outputs addObject:kHdmi];
        } else if ([portType isEqualToString:AVAudioSessionPortAirPlay]) {
            [outputs addObject:kAirPlay];
        } else if ([portType isEqualToString:AVAudioSessionPortBluetoothLE]) {
            [outputs addObject:kBluetoothLE];
        } else {
            [outputs addObject:kUnknown];
        }
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[outputs copy]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) overrideOutput:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult;
    NSString* output = [command.arguments objectAtIndex:0];
    BOOL success;
    NSError* error;

    AVAudioSession* session = [AVAudioSession sharedInstance];
    if (output != nil) {
        if ([output isEqualToString:@"speaker"]) {
            success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        } else {
            success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        }
        if (success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"'output' was null"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
