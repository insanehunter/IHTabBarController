/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
@class IHTabBar;

@interface IHTabBarView : UIView
{
    UIView *_contentView_weakref;
    IHTabBar *_tabBar_weakref;
}
@property(nonatomic, assign) UIView *contentView;
@property(nonatomic, assign) IHTabBar *tabBar;

@end
