/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
#import "IHTabBarView.h"
#import "IHTabBar.h"

@implementation IHTabBarView
@synthesize contentView = _contentView_weakref;
@synthesize tabBar = _tabBar_weakref;

- (void) setTabBar:(IHTabBar *)tabBar
{
    NSParameterAssert(tabBar != nil);
    
    [_tabBar_weakref removeFromSuperview];
    _tabBar_weakref = tabBar;
    [self addSubview:tabBar];
}

- (void) setContentView:(UIView *)contentView
{
    NSParameterAssert(contentView != nil);
    NSAssert(_tabBar_weakref != nil, nil);
    
    [_contentView_weakref removeFromSuperview];
    _contentView_weakref = contentView;
    CGSize bounds = self.bounds.size;
    contentView.frame = CGRectMake(0, 0, bounds.width,
                                   bounds.height - _tabBar_weakref.bounds.size.height);
    [self addSubview:contentView];
    [self sendSubviewToBack:contentView];
}

- (void) layoutSubviews
{
    NSAssert(_tabBar_weakref != nil, nil);
    
    [super layoutSubviews];
    
    CGRect frame = _contentView_weakref.frame;
    frame.size.height = self.bounds.size.height - _tabBar_weakref.bounds.size.height;
    _contentView_weakref.frame = frame;
    [_contentView_weakref layoutSubviews];
}
@end
