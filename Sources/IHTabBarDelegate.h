/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
@class IHTabBar;

@protocol IHTabBarDelegate

- (void) tabBar:(IHTabBar *)tabBar didSelectTabAtIndex:(NSInteger)index;

@end
