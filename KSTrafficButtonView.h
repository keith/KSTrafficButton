@import Cocoa;

typedef NS_OPTIONS(NSUInteger, KSTrafficButtonType) {
    KSTrafficButtonTypeClose = 1 << 0,
    KSTrafficButtonTypeMinimize = 1 << 1,
    KSTrafficButtonTypeFullscreen = 1 << 2,
    KSTrafficButtonTypeMaximize = 1 << 3,
    KSTrafficButtonTypeFullscreenMaximize = 1 << 4,
};

@interface KSTrafficButtonView : NSView

- (instancetype)initWithButtons:(KSTrafficButtonType)buttonsTypes;
- (instancetype)initWithButtons:(KSTrafficButtonType)buttonsTypes
                   defaultImage:(NSImage *)image;

@end
