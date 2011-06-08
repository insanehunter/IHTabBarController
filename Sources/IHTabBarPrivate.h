/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
#import "IHTabBar.h"

@interface IHTabBar (Private)

- (UIImage *) tabBarItemSelectionBackground;
- (UIImage *) tabBarItemMaskableBackground;
- (UIImage *) imageWithContentsOfFile:(NSString *)path;

@end
