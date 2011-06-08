/*
 * (c) Sergei Cherepanov, 2011
 * Based on Brian Collins' BCTabBarController
 */
#import "IHTabBarPrivate.h"
#import "IHTabBarItem.h"

@interface IHTabBarItem ()
- (UIImage *) createSelectedImageFrom:(UIImage *)image background:(UIImage *)background;
@end

#pragma mark -
@implementation IHTabBarItem
#pragma mark Initialization & deallocation
- (id) initWithIconImage:(UIImage *)image
{
    NSParameterAssert(image != nil);
    
    if (!(self = [super init]))
        return nil;
    
    [self setImage:image forState:UIControlStateNormal];
    self.adjustsImageWhenHighlighted = NO;
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (void) willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview == nil && newSuperview != nil)
    {
        NSAssert([newSuperview isKindOfClass:[IHTabBar class]], nil);
        
        UIImage *image = [self imageForState:UIControlStateNormal];
        UIImage *normalImage = [self createSelectedImageFrom:image background:nil];
        UIImage *maskableBackground = [(IHTabBar *)newSuperview tabBarItemMaskableBackground];
        UIImage *selectedImage = [self createSelectedImageFrom:image
                                                    background:maskableBackground];
        [self setImage:normalImage forState:UIControlStateNormal];
        [self setImage:selectedImage forState:UIControlStateSelected];
    }
}


#pragma mark - Layout & redraw
- (void) setHighlighted:(BOOL)highlighted
{
    // No highlighted state.
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize selfSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    int insetX = (int)((selfSize.width - imageSize.width) / 2);
    int insetY = (int)((selfSize.height - imageSize.height) / 2);
    self.imageEdgeInsets = UIEdgeInsetsMake(insetY, insetX, insetY, insetX);
}

- (void) drawRect:(CGRect)rect
{
    NSAssert([self.superview isKindOfClass:[IHTabBar class]], nil);
    if (self.selected)
    {
        CGSize bounds = self.bounds.size;
        UIImage *selectionBackground = [(IHTabBar *)self.superview tabBarItemSelectionBackground];
        [selectionBackground drawInRect:CGRectMake(0, 4, bounds.width, bounds.height - 4)];
    }
}


#pragma mark - Miscellaneous
-(UIImage *) blackFilledImageWithWhiteBackgroundUsing:(UIImage *)startImage
{
    NSParameterAssert(startImage != nil);
    
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(startImage.CGImage),
                                  CGImageGetHeight(startImage.CGImage));
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width,
                                                 imageRect.size.height, 8, 0,
                                                 CGImageGetColorSpace(startImage.CGImage),
                                                 kCGImageAlphaPremultipliedLast);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, imageRect);
    
    CGContextClipToMask(context, imageRect, startImage.CGImage);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, imageRect);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale
                                      orientation:startImage.imageOrientation];
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    return newImage;
}

- (UIImage *) createSelectedImageFrom:(UIImage *)image background:(UIImage *)background
{
    NSParameterAssert(image != nil);
    
    // Generating right-sized background image.
    CGSize targetSize = image.size;
    UIImage *croppedBackgroundImage = background;
    if (background == nil)
    {
        UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0f);
        [[UIColor lightGrayColor] set];
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, targetSize.width,
                                                                    targetSize.height));
        croppedBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (!CGSizeEqualToSize(background.size, image.size))
    {
        CGSize origSize = background.size;
        UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0f);
        [background drawInRect:CGRectMake((targetSize.width - origSize.width ) / 2,
                                          (targetSize.height - origSize.height) / 2,
                                          origSize.width, origSize.height)];
        croppedBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    NSAssert(croppedBackgroundImage != nil, nil);
    
    // Creating masked image.
    UIImage *bwImage = [self blackFilledImageWithWhiteBackgroundUsing:image];
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(bwImage.CGImage),
                                             CGImageGetHeight(bwImage.CGImage),
                                             CGImageGetBitsPerComponent(bwImage.CGImage),
                                             CGImageGetBitsPerPixel(bwImage.CGImage),
                                             CGImageGetBytesPerRow(bwImage.CGImage),
                                             CGImageGetDataProvider(bwImage.CGImage), NULL, YES);
    CGImageRef tabBarImageRef = CGImageCreateWithMask(croppedBackgroundImage.CGImage, imageMask);
    UIImage *tabBarImage = [UIImage imageWithCGImage:tabBarImageRef scale:[UIScreen mainScreen].scale
                                         orientation:image.imageOrientation];
    CGImageRelease(imageMask);
    CGImageRelease(tabBarImageRef);
    return tabBarImage;
}
@end
