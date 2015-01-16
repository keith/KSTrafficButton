#import "KSCloseTrafficButton.h"
#import "KSTrafficButton.h"
#import "KSTrafficButtonView.h"

@interface KSTrafficButtonView ()

@property (nonatomic) BOOL mouseInside;

@end

@implementation KSTrafficButtonView

static CGFloat const KSButtonSpacing = 8;

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

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor yellowColor] CGColor];

    NSUInteger styleMask = self.window.styleMask;
    KSTrafficButtonType types = [self buttonTypesWithWindowMask:styleMask];
    NSAssert(types > 0, @"Your window must have a styleMask");
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
    KSTrafficButton *b1 = buttons.firstObject;
    KSTrafficButton *b2 = buttons[1];
    KSTrafficButton *b3 = buttons.lastObject;

    [self addSubview:b1];
    [self addSubview:b2];
    [self addSubview:b3];

    b1.delegate = self;
    b2.delegate = self;
    b3.delegate = self;

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[b1]-(8)-[b2]-(8)-[b3]|" options:0 metrics:nil views:@{@"b1": b1, @"b2": b2, @"b3": b3}]];

    return;

    BOOL isFirstButton = YES;
    NSUInteger count = buttons.count;
    for (NSUInteger i = 0; i < count; i++) {
        KSTrafficButton *button = buttons[i];
        [self addSubview:button];
        if (isFirstButton) {
            [self addConstraint:
             [NSLayoutConstraint constraintWithItem:button
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0f
                                           constant:0]];
        } else {
            KSTrafficButton *previousButton = buttons[i - 1];
            [self addConstraints:[self constraintForButton:button
                                                 toButton:previousButton]];
        }

        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:@{@"button": button}]];

        isFirstButton = NO;
    }

    KSTrafficButton *lastButton = buttons[count - 1];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:lastButton
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1.0f
                                   constant:0]];

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
    return NSMakeSize(52, 12);
}

- (NSArray *)constraintForButton:(KSTrafficButton *)firstButton
                        toButton:(KSTrafficButton *)secondButton
{
    NSDictionary *metrics = @{@"spacing": @(KSButtonSpacing)};
    NSDictionary *views = NSDictionaryOfVariableBindings(firstButton, secondButton);
    return [NSLayoutConstraint constraintsWithVisualFormat:@"H:[firstButton]-(spacing)-[secondButton]" options:kNilOptions metrics:metrics views:views];
    //    return [NSLayoutConstraint constraintWithItem:firstButton
    //                                        attribute:NSLayoutAttributeRight
    //                                        relatedBy:NSLayoutRelationEqual
    //                                           toItem:secondButton
    //                                        attribute:NSLayoutAttributeLeft
    //                                       multiplier:1.0f
    //                                         constant:KSButtonSpacing];
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
