@import Cocoa;

typedef NS_OPTIONS(NSUInteger, KSTrafficButtonType) {
    KSTrafficButtonTypeClose = 1 << 0,
    KSTrafficButtonTypeMinimize = 1 << 1,
    KSTrafficButtonTypeMaximize = 1 << 2,
};

@interface KSTrafficButtonView : NSView

- (instancetype)initWithButtons:(KSTrafficButtonType)buttonsTypes;
- (instancetype)initWithButtons:(KSTrafficButtonType)buttonsTypes
                   defaultImage:(NSImage *)image;

@end
