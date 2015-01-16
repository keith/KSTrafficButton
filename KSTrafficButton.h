@import Cocoa;

@interface KSTrafficButton : NSButton

@property (nonatomic, readonly) BOOL mouseDown;
@property (nonatomic) BOOL hasSiblingDown;
@property (nonatomic) BOOL insideGroupView;
@property (nonatomic, weak) NSResponder *delegate;

+ (instancetype)buttonWithBaseImage:(NSImage *)baseImage
                     mouseDownImage:(NSImage *)mouseDownImage
                     mouseOverImage:(NSImage *)mouseOverImage;

- (instancetype)initWithCoder:(NSCoder *)coder
                    baseImage:(NSImage *)baseImage
               mouseDownImage:(NSImage *)mouseDownImage
               mouseOverImage:(NSImage *)mouseOverImage;

- (instancetype)initWithBaseImage:(NSImage *)baseImage
                   mouseDownImage:(NSImage *)mouseDownImage
                   mouseOverImage:(NSImage *)mouseOverImage;

@end
