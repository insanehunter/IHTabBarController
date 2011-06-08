/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
#import "IHTabBarDelegate.h"
@class IHTabBarItem;

@interface IHTabBar : UIView
{
    NSArray *_tabs;
    IHTabBarItem *_selectedTab_weakref;
    
    UIImageView *_arrowImageView;
    UIImage *_backgroundImage;
    UIImage *_itemSelectionBackgroundImage;
    UIImage *_itemMaskableBackground;
    UIImage *_defaultItemImage;
    id<IHTabBarDelegate> _delegate_weakref;
}
@property(nonatomic, copy) NSArray *tabs;
@property(nonatomic, assign) IHTabBarItem *selectedTab;
@property(nonatomic, assign) id<IHTabBarDelegate> delegate;
@property(nonatomic, readonly) UIImage *defaultItemImage;

- (id) initWithFrame:(CGRect)frame;

- (void) setSelectedTab:(IHTabBarItem *)selectedTab animated:(BOOL)animated;

@end
