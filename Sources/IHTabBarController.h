/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
#import "IHTabBarDelegate.h"
@class IHTabBarView;

@interface IHTabBarController : UIViewController <IHTabBarDelegate>
{
    NSArray *_viewControllers;
    UIViewController *_selectedViewController_weakref;
    IHTabBar *_tabBar_weakref;
    IHTabBarView *_tabBarView_weakref;
    BOOL _visible;
}
@property(nonatomic, readonly) IHTabBar *tabBar;
@property(nonatomic, readonly) IHTabBarView *tabBarView;
@property(nonatomic, copy) NSArray *viewControllers;
@property(nonatomic, assign) UIViewController *selectedViewController;
@property(nonatomic, assign) NSUInteger selectedIndex;

@end
