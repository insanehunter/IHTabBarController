### IHTabBarController

IHTabBarController is a Tweetie-style tab bar for iPhone. See below for screenshots.
It is a complete rewrite of Brian Collins' [BCTabBarController](https://github.com/briancollins/BCTabBarController) intended to reduce
image footprint and improve readability.

### Features

* A cool little arrow that slides around to indicate the current tab
* Support for all orientations
* Same height as a standard UIToolbar
* TabBar item normal and selected icons are generated from user-provided image.

### Usage
* Add IHTabBarController/Sources directory to your project.
* Create IHTabBarController in your AppDelegate and add some ViewControllers to it:

    _tabBarController = [[IHTabBarController alloc] init];
    _tabBarController.viewControllers = [NSArray arrayWithObjects:
                                            [[[UIViewController alloc] init] autorelease],
                                            [[[UIViewController alloc] init] autorelease],
                                            [[[UINavigationController alloc] initWithRootViewController:
                                                    [[[UIViewController alloc] init] autorelease]] autorelease],
                                           			nil];
    [_window addSubview:_tabBarController.view];

* Add `- (UIImage *) tabBarImage` method to all your ViewControllers

