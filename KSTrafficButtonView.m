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
    NSAssert(types > 0, @"Your window must have a style mask");
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
        NSRect rect = self.bounds;
//        rect.size = self.intrinsicContentSize;
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:rect
                                    options:options
                                    owner:self
                                    userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)setupWithButtons:(NSArray *)buttons
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];


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


//    [b2 addTrackingArea:trackingArea];
//    [b3 addTrackingArea:trackingArea];

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


    NSTrackingAreaOptions options = (

                                     NSTrackingActiveAlways | NSTrackingEnabledDuringMouseDrag |
                                     NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved
//                                     NSTrackingActiveAlways |
//                                     NSTrackingEnabledDuringMouseDrag |
//                                     NSTrackingMouseMoved
                                     );
        NSRect rect = self.bounds;
        rect.size = self.intrinsicContentSize;
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:rect
                                    options:options
                                    owner:self
                                    userInfo:nil];
    [button addTrackingArea:trackingArea];
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
    NSLog(@"Enter");
    self.mouseInside = YES;
    for (KSTrafficButton *button in self.subviews) {
        if (![button isKindOfClass:[KSTrafficButton class]]) {
            NSLog(@"%@ is not button", button);
        }

        [button mouseEntered:theEvent];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSLog(@"Exit");
    BOOL down = NO;
    self.mouseInside = NO;
    for (KSTrafficButton *button in self.subviews) {
        if (button.mouseDown) {
            down = YES;
            return;
        }
    }
    
    for (KSTrafficButton *button in self.subviews) {
        if (![button isKindOfClass:[KSTrafficButton class]]) {
            NSLog(@"%@ 2 is not button", button);
        }

//        if (down) {
//            [button mouseDown:nil];
//        }

        [button mouseExited:theEvent];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSLog(@"Moved");
}

- (void)cursorUpdate:(NSEvent *)event
{
    NSLog(@"Cursor update");
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"Down");
//    NSPoint location = [NSEvent mouseLocation];
    NSPoint windowLocation = [theEvent locationInWindow];
    NSPoint viewLocation = [self convertPoint:windowLocation fromView:nil];

    if (!NSPointInRect(viewLocation, self.bounds)) {
        NSLog(@"%@ isnt in %@", NSStringFromPoint(viewLocation), NSStringFromRect(self.bounds));
    }

//    KSTrafficButton *button = [self hitTest:[theEvent locationInWindow]]
    KSTrafficButton *button = (KSTrafficButton *)[self hitTest:[theEvent locationInWindow]];

    if ([button isKindOfClass:[self class]]) {
        NSLog(@"Need to guard self");
        return;
    }

    if (![button isKindOfClass:[KSTrafficButton class]]) {
        NSLog(@"%@ isn't a button", button);
        return;
    }

    [button mouseDown:theEvent];
//    NSPoint globalLocation = [ NSEvent mouseLocation ];
//    NSPoint windowLocation = [ [ myView window ] convertScreenToBase: globalLocation ];
//    NSPoint viewLocation = [ myView convertPoint: windowLocation fromView: nil ];
//    if( NSPointInRect( viewLocation, [ myView bounds ] ) ) {
//    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSLog(@"Up");
    if (!self.mouseInside) {
        NSLog(@"Up outside");
        for (KSTrafficButton *button in self.subviews) {
            [button mouseExited:nil];
        }
    }
}

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(1, 12);
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
    
    if ((mask & KSTrafficButtonTypeFullscreen) == KSTrafficButtonTypeFullscreen) {
        [array addObject:[KSCloseTrafficButton new]];
    }
    
    if ((mask & KSTrafficButtonTypeMaximize) == KSTrafficButtonTypeMaximize) {
        [array addObject:[KSCloseTrafficButton new]];
    }
    
    if ((mask & KSTrafficButtonTypeFullscreenMaximize) == KSTrafficButtonTypeFullscreenMaximize) {
        [array addObject:[KSCloseTrafficButton new]];
    }
    
    NSAssert(array.count <= 3, @"Only 3 traffic buttons are allowed!");
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
    
    if ((windowMask & NSFullScreenWindowMask) == NSFullScreenWindowMask) {
        if ((windowMask & NSResizableWindowMask) == NSResizableWindowMask) {
            buttonTypes |= KSTrafficButtonTypeFullscreenMaximize;
        } else {
            buttonTypes |= KSTrafficButtonTypeFullscreen;
        }
    } else if ((windowMask & NSResizableWindowMask) == NSResizableWindowMask) {
        buttonTypes |= KSTrafficButtonTypeMaximize;
    }

    return buttonTypes;
}


@end
