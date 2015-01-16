#import "KSCloseTrafficButton.h"
#import "KSTrafficButtonConstants.h"

@implementation KSCloseTrafficButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSImage *baseImage = [NSImage imageNamed:KSCloseBaseImageName];
    NSImage *mouseDownImage = [NSImage imageNamed:KSCloseMouseDownImageName];
    NSImage *mouseOverImage = [NSImage imageNamed:KSCloseMouseOverImageName];
    return [super initWithCoder:coder
                      baseImage:baseImage
                 mouseDownImage:mouseDownImage
                 mouseOverImage:mouseOverImage];
}

- (instancetype)init
{
    NSImage *baseImage = [NSImage imageNamed:KSCloseBaseImageName];
    NSImage *mouseDownImage = [NSImage imageNamed:KSCloseMouseDownImageName];
    NSImage *mouseOverImage = [NSImage imageNamed:KSCloseMouseOverImageName];
    return [super initWithBaseImage:baseImage
                     mouseDownImage:mouseDownImage
                     mouseOverImage:mouseOverImage];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    self.target = self.window;
    self.action = @selector(close);
}

@end
