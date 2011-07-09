/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
#import "IHTabBarPrivate.h"
#import "IHTabBarItem.h"

// All IHTabBarController resources are managed by IHTabBar.
#define IHTABBAR_SHOW_ARROW                 0
#define IHTABBAR_BUNDLE                     @"IHTabBarController.bundle/"
#define IHTABBAR_BACKGROUND_ASSET           (IHTABBAR_BUNDLE @"background.png")
#define IHTABBAR_ARROW_ASSET                (IHTABBAR_BUNDLE @"arrow.png")
#define IHTABBAR_ITEM_BACKGROUND_ASSET      (IHTABBAR_BUNDLE @"tab-background.png")
#define IHTABBAR_ITEM_MASKABLE_ASSET        (IHTABBAR_BUNDLE @"tab-icon-mask.png")
#define IHTABBAR_DEFAULT_ITEM_ASSET         (IHTABBAR_BUNDLE @"default-icon.png")

@implementation IHTabBar
@synthesize tabs = _tabs;
@synthesize selectedTab = _selectedTab_weakref;
@synthesize delegate = _delegate_weakref;
@dynamic defaultItemImage;

#pragma mark Initialization & deallocation
- (id) initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Background
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *backgroundImagePath = [bundlePath stringByAppendingPathComponent:IHTABBAR_BACKGROUND_ASSET];
    _backgroundImage = [[self imageWithContentsOfFile:backgroundImagePath] retain];
    NSAssert(_backgroundImage != nil, nil);
    
#if IHTABBAR_SHOW_ARROW
    // Arrow
    UIImage *arrowImage = [self imageWithContentsOfFile:
                                    [bundlePath stringByAppendingPathComponent:IHTABBAR_ARROW_ASSET]];
    NSAssert(arrowImage != nil, nil);
    _arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
    CGRect rect = _arrowImageView.frame;
    rect.origin.y = -(rect.size.height - 2);
    _arrowImageView.frame = rect;
    [self addSubview:_arrowImageView];
#endif // IHTABBAR_SHOW_ARROW
    
    // Item images
    NSString *selectionImagePath = [bundlePath stringByAppendingPathComponent:IHTABBAR_ITEM_BACKGROUND_ASSET];
    UIImage *selectionImage = [self imageWithContentsOfFile:selectionImagePath];
    NSAssert(selectionImage != nil, nil);
    _itemSelectionBackgroundImage = [[selectionImage stretchableImageWithLeftCapWidth:5
                                                                         topCapHeight:0] retain];
    NSString *maskableImagePath = [bundlePath stringByAppendingPathComponent:IHTABBAR_ITEM_MASKABLE_ASSET];
    _itemMaskableBackground = [[self imageWithContentsOfFile:maskableImagePath] retain];
    NSAssert(_itemMaskableBackground != nil, nil);
    
    self.userInteractionEnabled = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    return self;
}

- (void) dealloc
{
    [_tabs release];
    [_arrowImageView release];
    [_backgroundImage release];
    [_itemSelectionBackgroundImage release];
    [_itemMaskableBackground release];
    [_defaultItemImage release];
    [super dealloc];
}


#pragma mark - Actions
- (void) tabSelectedAction:(IHTabBarItem *)sender
{
    [self.delegate tabBar:self didSelectTabAtIndex:[self.tabs indexOfObject:sender]];
}

- (void) positionArrowAnimated:(BOOL)animated
{
#if IHTABBAR_SHOW_ARROW
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];
    }
    CGRect rect = _arrowImageView.frame;
    CGRect tabRect = _selectedTab_weakref.frame;
    rect.origin.x = tabRect.origin.x + floorf((tabRect.size.width - rect.size.width) / 2);
    _arrowImageView.frame = rect;
    
    if (animated)
        [UIView commitAnimations];
#endif // IHTABBAR_SHOW_ARROW
}


#pragma mark - Getters & setters
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void) setTabs:(NSArray *)array
{
    NSParameterAssert(array != nil);
    NSParameterAssert([array count] > 0);
    
    for (IHTabBarItem *tab in _tabs)
        [tab removeFromSuperview];
    
    [_tabs release];
    _tabs = [array copy];
    
    for (IHTabBarItem *tab in _tabs)
    {
        NSAssert([tab isKindOfClass:[IHTabBarItem class]], nil);
        
        tab.userInteractionEnabled = YES;
        [tab addTarget:self action:@selector(tabSelectedAction:)
             forControlEvents:UIControlEventTouchDown];
    }
    [self setSelectedTab:[_tabs objectAtIndex:0] animated:NO];
    [self setNeedsLayout];
}

- (void) setSelectedTab:(IHTabBarItem *)selectedTab
{
    [self setSelectedTab:selectedTab animated:YES];
}

- (void) setSelectedTab:(IHTabBarItem *)selectedTab animated:(BOOL)animated
{
    NSParameterAssert(selectedTab);
    NSAssert([_tabs indexOfObject:selectedTab] != NSNotFound, nil);
    
    if (selectedTab != _selectedTab_weakref)
    {
        _selectedTab_weakref = selectedTab;
        _selectedTab_weakref.selected = YES;
        
        for (IHTabBarItem *tab in _tabs)
            if (tab != selectedTab)
                tab.selected = NO;
    }
    [self positionArrowAnimated:animated];
}

- (UIImage *) defaultItemImage
{
    if (_defaultItemImage == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *imagePath = [bundlePath stringByAppendingPathComponent:IHTABBAR_DEFAULT_ITEM_ASSET];
        _defaultItemImage = [[self imageWithContentsOfFile:imagePath] retain];
        NSAssert(_defaultItemImage != nil, nil);
    }
    return _defaultItemImage;
}


#pragma mark - Layout & redraw
- (void) drawRect:(CGRect)rect
{
    CGSize bounds = self.bounds.size;
    [_backgroundImage drawInRect:CGRectMake(0, 0, bounds.width, bounds.height)];
}

- (void) layoutSubviews
{
    NSAssert([_tabs count] != 0, nil);
    NSAssert(_selectedTab_weakref != nil, nil);
    [super layoutSubviews];
    
    const NSUInteger MARGIN = 2;
    const NSUInteger tabCount = [_tabs count];
    CGRect rect = self.bounds;
    rect.size.width -= MARGIN * (tabCount + 1);
    rect.size.width = floorf(rect.size.width / tabCount);
    for (IHTabBarItem *tab in _tabs)
    {
        rect.origin.x += MARGIN;
        tab.frame = rect;
        [self addSubview:tab];
        rect.origin.x += rect.size.width;
    }
    [self positionArrowAnimated:NO];
}
@end

#pragma mark -
@implementation IHTabBar (Private)
- (UIImage *) tabBarItemSelectionBackground
{
    return _itemSelectionBackgroundImage;
}

- (UIImage *) tabBarItemMaskableBackground
{
    return _itemMaskableBackground;
}

- (UIImage *) imageWithContentsOfFile:(NSString *)path
{
    NSParameterAssert(path != nil);
    
    // iOS 4.0 retina image loading issue workaround.
    if ([UIScreen instancesRespondToSelector:@selector(scale)] &&
        [[UIScreen mainScreen] scale] == 2.0)
    {
        NSString *ext = [path pathExtension];
        NSString *basePath = [path stringByDeletingPathExtension];
        NSString *path2x = [[basePath stringByAppendingString:@"@2x"] stringByAppendingPathExtension:ext];
		if ([[NSFileManager defaultManager] fileExistsAtPath:path2x])
        {
            UIImage *image2x = [UIImage imageWithData:[NSData dataWithContentsOfFile:path2x]];
            return [UIImage imageWithCGImage:image2x.CGImage scale:2.0f
                                 orientation:UIImageOrientationUp];
        }
	}
    return [UIImage imageWithContentsOfFile:path];
}
@end
