#import "KSTrafficButton.h"

@interface KSTrafficButton ()

@property (nonatomic) NSImage *baseImage;
@property (nonatomic) NSImage *mouseDownImage;
@property (nonatomic) NSImage *mouseOverImage;

@property (nonatomic, readwrite) BOOL mouseDown;
@property (nonatomic) BOOL mouseInside;

@end

static NSInteger const KSTrafficButtonWidth = 12;

@implementation KSTrafficButton

+ (instancetype)buttonWithBaseImage:(NSImage *)baseImage
                     mouseDownImage:(NSImage *)mouseDownImage
                     mouseOverImage:(NSImage *)mouseOverImage
{
    return [[self alloc] initWithBaseImage:baseImage
                            mouseDownImage:mouseDownImage
                            mouseOverImage:mouseOverImage];
}

- (instancetype)initWithBaseImage:(NSImage *)baseImage
                   mouseDownImage:(NSImage *)mouseDownImage
                   mouseOverImage:(NSImage *)mouseOverImage
{
    self = [super init];
    if (!self) return nil;

    [self setupWithBaseImage:baseImage
              mouseDownImage:mouseDownImage
              mouseOverImage:mouseOverImage];
    [self setupTracking];

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
                    baseImage:(NSImage *)baseImage
               mouseDownImage:(NSImage *)mouseDownImage
               mouseOverImage:(NSImage *)mouseOverImage
{
    self = [super initWithCoder:coder];
    if (!self) return nil;

    [self setupWithBaseImage:baseImage
              mouseDownImage:mouseDownImage
              mouseOverImage:mouseOverImage];
    [self setupTracking];

    return self;
}

- (void)setupWithBaseImage:(NSImage *)baseImage
            mouseDownImage:(NSImage *)mouseDownImage
            mouseOverImage:(NSImage *)mouseOverImage
{
    NSParameterAssert(baseImage);
    NSParameterAssert(mouseDownImage);
    NSParameterAssert(mouseOverImage);

    self.baseImage = baseImage;
    self.mouseDownImage = mouseDownImage;
    self.mouseOverImage = mouseOverImage;
}

- (void)setupTracking
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CALayer *layer = [CALayer layer];
    self.wantsLayer = YES;
    self.layer = layer;
    self.layer.contents = self.baseImage;

    NSTrackingAreaOptions options = (

                                     NSTrackingActiveAlways
                                     | NSTrackingEnabledDuringMouseDrag
                                     | NSTrackingMouseEnteredAndExited
                                     //| NSTrackingMouseMoved
//                                     | NSTrackingAssumeInside
                                     | NSTrackingInVisibleRect
//                                     | NSTrackingCursorUpdate

//                                     NSTrackingMouseEnteredAndExited |
//                                     NSTrackingActiveAlways |
//                                     NSTrackingEnabledDuringMouseDrag
//                                     NSTrackingMouseMoved
                                     );
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:self.bounds
                                    options:options
                                    owner:self
                                    userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(KSTrafficButtonWidth, KSTrafficButtonWidth);
}

#pragma mark - Mouse events

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseInside = YES;
    if (self.mouseDown) {
        self.layer.contents = self.mouseDownImage;
    } else {
        self.layer.contents = self.mouseOverImage;
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.mouseInside = NO;
    if (self.mouseDown || self.hasSiblingDown || self.insideGroupView) {
        self.layer.contents = self.mouseOverImage;
    } else {
        self.layer.contents = self.baseImage;
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    self.mouseDown = YES;
    self.layer.contents = self.mouseDownImage;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    self.mouseDown = NO;
    if (self.mouseInside) {
        self.layer.contents = self.mouseOverImage;
        [self sendAction:self.action to:self.target];
    } else {
        if (self.insideGroupView) {
            self.layer.contents = self.mouseOverImage;
        } else {
            self.layer.contents = self.baseImage;
        }
    }

    [self.delegate mouseUp:theEvent];
}

@end
