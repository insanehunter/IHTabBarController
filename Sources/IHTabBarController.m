/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
#import "IHTabBarController.h"
#import "IHTabBarView.h"
#import "IHTabBarItem.h"
#import "IHTabBar.h"

@interface UIViewController (IHTabBar)
- (UIImage *) tabBarImage;
@end

@interface IHTabBarController ()
- (void) loadTabs;
@end

#pragma mark -
@implementation IHTabBarController
@synthesize tabBar = _tabBar;
@synthesize tabBarView = _tabBarView;
@synthesize viewControllers = _viewControllers;
@synthesize selectedViewController = _selectedViewController_weakref;
@dynamic selectedIndex;

#pragma mark Initialization & deallocation
- (void) loadView
{
    NSAssert(_tabBarView == nil, nil);
    NSAssert(_tabBar == nil, nil);
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    _tabBarView_weakref = [[[IHTabBarView alloc] initWithFrame:frame] autorelease];
    _tabBarView_weakref.opaque = NO;
    _tabBarView_weakref.backgroundColor = [UIColor clearColor];
    self.view = _tabBarView_weakref;
    
    _tabBar_weakref = [[[IHTabBar alloc] initWithFrame:CGRectMake(0, frame.size.height - 44,
                                                                  frame.size.width, 44)] autorelease];
    _tabBar_weakref.delegate = self;
    _tabBarView_weakref.tabBar = _tabBar_weakref;
    
    [self loadTabs];
    UIViewController *selectedController = _selectedViewController_weakref;
    _selectedViewController_weakref = nil;
    [self setSelectedViewController:selectedController];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    
    _tabBarView_weakref = nil;
    _tabBar_weakref = nil;
}

- (void) dealloc
{
    self.viewControllers = nil;
    [super dealloc];
}


#pragma mark - UIViewController
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_selectedViewController_weakref viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_selectedViewController_weakref viewDidAppear:animated];
    _visible = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_selectedViewController_weakref viewWillDisappear:animated];    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_selectedViewController_weakref viewDidDisappear:animated];
    _visible = NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [_selectedViewController_weakref shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                 duration:(NSTimeInterval)duration
{
    [_selectedViewController_weakref willRotateToInterfaceOrientation:toInterfaceOrientation
                                                             duration:duration];
}

- (void) willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                                     duration:(NSTimeInterval)duration
{
    [_selectedViewController_weakref willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation
                                                                                 duration:duration];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                          duration:(NSTimeInterval)duration
{
    [_selectedViewController_weakref willAnimateRotationToInterfaceOrientation:interfaceOrientation
                                                                      duration:duration];
}

- (void) willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
                                                        duration:(NSTimeInterval)duration
{
    [_selectedViewController_weakref willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation
                                                                                    duration:duration];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_selectedViewController_weakref didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark - Getters & setters
- (void) setViewControllers:(NSArray *)array
{
    NSParameterAssert(array != nil);
    
    if (array != _viewControllers)
    {
        [_viewControllers release];
        _viewControllers = [array copy];
        [self loadTabs];
    }
    self.selectedIndex = 0;
}

- (void) setSelectedViewController:(UIViewController *)vc
{
    NSParameterAssert(vc != nil);
    NSAssert([_viewControllers indexOfObject:vc] != NSNotFound, nil);
    
    UIViewController *oldVC = [[_selectedViewController_weakref retain] autorelease];
    if (oldVC != vc)
    {
        [_selectedViewController_weakref release];
        _selectedViewController_weakref = [vc retain];
        if (_visible)
        {
            [oldVC viewWillDisappear:NO];
            [_selectedViewController_weakref viewWillAppear:NO];
        }
        _tabBarView_weakref.contentView = vc.view;
        if (_visible)
        {
            [oldVC viewDidDisappear:NO];
            [_selectedViewController_weakref viewDidAppear:NO];
        }
        [_tabBar_weakref setSelectedTab:[_tabBar_weakref.tabs objectAtIndex:self.selectedIndex]
                               animated:(oldVC != nil)];
    }
}

- (NSUInteger) selectedIndex
{
    NSAssert(_viewControllers != nil, nil);
    
    return [_viewControllers indexOfObject:_selectedViewController_weakref];
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex
{
    NSAssert(_viewControllers != nil, nil);
    NSParameterAssert(selectedIndex < [_viewControllers count]);
    
    self.selectedViewController = [_viewControllers objectAtIndex:selectedIndex];
}


#pragma mark - Miscellaneous
- (void) tabBar:(IHTabBar *)tabBar didSelectTabAtIndex:(NSInteger)tabIndex
{
    UIViewController *vc = [_viewControllers objectAtIndex:tabIndex];
    if (_selectedViewController_weakref == vc)
    {
        if ([self.selectedViewController isKindOfClass:[UINavigationController class]])
            [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:YES];
    }
    else
        self.selectedViewController = vc;
}

- (void) loadTabs
{
    if (_tabBar_weakref == nil)
        return;
    
    NSMutableArray *tabs = [NSMutableArray arrayWithCapacity:[_viewControllers count]];
    for (UIViewController *vc in _viewControllers)
    {
        UIImage *itemImage = nil;
        if ([vc isKindOfClass:[UINavigationController class]])
            vc = ((UINavigationController *)vc).topViewController;
        
        if ([vc respondsToSelector:@selector(tabBarImage)])
            itemImage = [vc tabBarImage];
        if (itemImage == nil)
            itemImage = _tabBar_weakref.defaultItemImage;
        [tabs addObject:[[[IHTabBarItem alloc] initWithIconImage:itemImage] autorelease]];
    }
    _tabBar_weakref.tabs = tabs;
    [_tabBar_weakref setSelectedTab:[_tabBar_weakref.tabs objectAtIndex:self.selectedIndex] animated:NO];
}
@end
