#import "KSCloseTrafficButton.h"
#import "KSTrafficButton.h"
#import "KSTrafficButtonConstants.h"
#import "KSTrafficButtonView.h"

@interface KSTrafficButtonView ()

@property (nonatomic) BOOL mouseInside;

@end

@implementation KSTrafficButtonView

static CGFloat const KSTrafficButtonSpacing = 8;

- (instancetype)initWithButtons:(KSTrafficButtonType)buttonTypes
{
    return [self initWithButtons:buttonTypes defaultImage:nil];
}

- (instancetype)initWithButtons:(KSTrafficButtonType)buttonsTypes
                   defaultImage:(NSImage *)image
{
    self = [super init];
    if (!self) return nil;

    NSArray *buttons = [self buttonsForMask:buttonsTypes
                           withDefaultImage:image];
    [self setupWithButtons:buttons];

    return self;
}

- (instancetype)initWithStyleMask:(NSUInteger)styleMask
{
    self = [super init];
    if (!self) return nil;

    [self setupWithStyleMask:styleMask];

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupWithStyleMask:self.window.styleMask];
}

- (void)setupWithStyleMask:(NSUInteger)styleMask
{
    KSTrafficButtonType types = [self buttonTypesWithWindowMask:styleMask];
    NSAssert(types > 0, @"Your window must have a valid styleMask");
    NSArray *buttons = [self buttonsForMask:types withDefaultImage:nil];
    [self setupWithButtons:buttons];
}

- (void)layoutSubtreeIfNeeded
{
    [super layoutSubtreeIfNeeded];
    if (self.trackingAreas.count > 0) {
        return;
    }
    
    NSTrackingAreaOptions options = (NSTrackingMouseEnteredAndExited |
                                     NSTrackingActiveAlways |
                                     NSTrackingEnabledDuringMouseDrag);
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:self.bounds
                                    options:options
                                    owner:self
                                    userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)setupWithButtons:(NSArray *)buttons
{
    NSUInteger index = 0;
    NSMutableDictionary *views = [NSMutableDictionary new];
    NSString *format = @"H:|";
    NSString *spacingFormat = [NSString stringWithFormat:@"-(%.0f)-",
                               KSTrafficButtonSpacing];
    for (KSTrafficButton *button in buttons) {
        button.delegate = self;
        [self addSubview:button];
        NSString *key = [NSString stringWithFormat:@"view%lu", (unsigned long)index];
        format = [format stringByAppendingFormat:@"[%@]%@", key, spacingFormat];
        views[key] = button;
        index++;
    }

    NSUInteger stringLength = format.length;
    NSUInteger spacingLength = spacingFormat.length;
    NSRange range = NSMakeRange(stringLength - spacingLength, spacingLength);
    format = [format stringByReplacingOccurrencesOfString:spacingFormat
                                               withString:@"|"
                                                  options:NSBackwardsSearch
                                                    range:range];

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:format
                                             options:kNilOptions
                                             metrics:nil
                                               views:views]];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseInside = YES;
    for (KSTrafficButton *button in self.subviews) {
        NSAssert([button isKindOfClass:[KSTrafficButton class]],
                 @"Don't put other views in the KSTrafficButtonView");

        button.insideGroupView = YES;
        if (!button.mouseDown) {
            [button mouseEntered:theEvent];
        }
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.mouseInside = NO;
    BOOL mouseIsDown = NO;
    for (KSTrafficButton *button in self.subviews) {
        button.insideGroupView = NO;
        if (button.mouseDown) {
            mouseIsDown = YES;
        }
    }
    
    for (KSTrafficButton *button in self.subviews) {
        NSAssert([button isKindOfClass:[KSTrafficButton class]],
                 @"Don't put other views in the KSTrafficButtonView");
        if (!button.mouseDown) {
            button.hasSiblingDown = mouseIsDown;
        }

        [button mouseExited:theEvent];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSView *view = [self hitTest:[theEvent locationInWindow]];
    if ([view isKindOfClass:[KSTrafficButton class]]) {
        [view mouseDown:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (!self.mouseInside) {
        for (KSTrafficButton *button in self.subviews) {
            NSAssert([button isKindOfClass:[KSTrafficButton class]],
                     @"Don't put other views in the KSTrafficButtonView");
            button.hasSiblingDown = NO;
            [button mouseExited:nil];
        }
    }
}

- (NSSize)intrinsicContentSize
{
    NSUInteger numberOfSubviews = self.subviews.count;
    CGFloat spacing = KSTrafficButtonSpacing * (numberOfSubviews - 1);
    CGFloat buttonWidths = KSTrafficButtonDimension * numberOfSubviews;
    return NSMakeSize(buttonWidths + spacing, KSTrafficButtonDimension);
}

- (NSArray *)buttonsForMask:(KSTrafficButtonType)mask withDefaultImage:(NSImage *)image
{
    NSMutableArray *array = [NSMutableArray new];
    if ((mask & KSTrafficButtonTypeClose) == KSTrafficButtonTypeClose) {
        [array addObject:[KSCloseTrafficButton new]];
    }
    
    if ((mask & KSTrafficButtonTypeMinimize) == KSTrafficButtonTypeMinimize) {
        [array addObject:[KSCloseTrafficButton new]];
    }
    
    if ((mask & KSTrafficButtonTypeMaximize) == KSTrafficButtonTypeMaximize) {
        [array addObject:[KSCloseTrafficButton new]];
    }

    return [array copy];
}

- (KSTrafficButtonType)buttonTypesWithWindowMask:(NSUInteger)windowMask
{
    KSTrafficButtonType buttonTypes;
    if ((windowMask & NSClosableWindowMask) == NSClosableWindowMask) {
        buttonTypes |= KSTrafficButtonTypeClose;
    }
    
    if ((windowMask & NSMiniaturizableWindowMask) == NSMiniaturizableWindowMask) {
        buttonTypes |= KSTrafficButtonTypeMinimize;
    }
    
    if ((windowMask & NSResizableWindowMask) == NSResizableWindowMask) {
        buttonTypes |= KSTrafficButtonTypeMaximize;
    }
    
    return buttonTypes;
}


@end
