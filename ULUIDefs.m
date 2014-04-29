//
//  ULUIDefs.m
//  United Libraries
//
//  Created by Mikhail Larionov on 1/01/14.
//

#import "ULUIDefs.h"

@implementation NSObject (PerformBlockAfterDelay)

- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block
{
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block
{
    block();
}

@end

@implementation ULTransitView

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for ( UIView* view in self.subviews )
    {
        if ( [view isKindOfClass:[ULTransitView class]] )
            if ( CGRectContainsPoint(view.frame, point) )
                return [view pointInside:CGPointMake(point.x-view.originX, point.y-view.originY) withEvent:event];
        if ( [view isKindOfClass:[UIButton class]] )
            if ( CGRectContainsPoint(view.frame, point) )
                return YES;
    }
    return NO;
}

@end

@implementation UIColor (HexColor)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if(cleanString.length == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if (cleanString.length == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF) / 255.f;
    float green = ((baseValue >> 16) & 0xFF) / 255.f;
    float blue = ((baseValue >> 8) & 0xFF) / 255.f;
    float alpha = ((baseValue >> 0) & 0xFF) / 255.f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

@implementation UIView (Coordinates)

- (void)setCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setOrigin:(CGPoint)origin
{
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGPoint)origin
{
    return CGPointMake(self.frame.origin.x, self.frame.origin.y);
}

- (void)setOriginX:(CGFloat)originX
{
    self.frame = CGRectMake(originX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)originX
{
    return self.frame.origin.x;
}

- (void)setOriginY:(CGFloat)originY
{
    self.frame = CGRectMake(self.frame.origin.x, originY, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)originY
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (CGSize)size
{
    return self.frame.size;
}

@end

@implementation UIView (Localise)

- (void)localize
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
    {
        [view localize];
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)view;
            if ( label.text.length > 0 )
                [label setText:NSLocalizedString(label.text, nil)];
        }
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)view;
            if ( button.titleLabel.text.length > 0 )
                [button setTitle:NSLocalizedString(button.titleLabel.text, nil) forState:UIControlStateNormal];
        }
    }];
}

- (void)scaleFonts
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
    {
        if ( view.tag != 777 )
        {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                UNI_UPDATE_FONT(label);
            }
            else if ([view isKindOfClass:[UITextView class]]) {
                UITextView *text = (UITextView*)view;
                UNI_UPDATE_FONT(text);
            }
            else if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton*)view;
                UNI_UPDATE_FONT(button.titleLabel);
            }
            else
                [view scaleFonts];
        }
    }];
}

- (void)scalePositions
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
    {
        if ( view.tag != 777 )
        {
            [view scalePositions];
            UNI_SHIFT_IPAD(view.frame, REPOSITION_TOPLEFT);
        }
    }];
}

@end

@implementation SKProduct (priceAsString)

- (NSString *) priceAsString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[self priceLocale]];
    
    NSString *str = [formatter stringFromNumber:[self price]];
    return str;
}

@end

@implementation UINavigationController (Transition)

- (UIViewController*) replaceViewController:(UIViewController*)controller
{
    // Transition
    CATransition* transition = [CATransition animation];
    transition.duration = 0.2;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    [(CALayer*)self.view.layer addAnimation:transition forKey:nil];
    
    // Pop
    UIViewController* oldOne = [self popViewControllerAnimated:NO];
    
    // Push
    [self pushViewController:controller animated:NO];
    
    return oldOne;
}

@end

@implementation UIImage (iPadSupport)

- (id)initWithContentsOfScalableFile:(NSString *)path
{
    UIImage* tempImage = nil;
    NSString* newPath;
    
    if ( IPAD && RETINA_MODE )
    {
        newPath = [NSString stringWithFormat:@"%@@2x~ipad.png", path];
        tempImage = [UIImage imageNamed:newPath];
        if ( tempImage )
            return [self initWithCGImage:[tempImage CGImage] scale:2.0 orientation:UIImageOrientationUp];
    }
    
    if ( IPAD )
    {
        newPath = [NSString stringWithFormat:@"%@.png", path];
        tempImage = [UIImage imageNamed:newPath];
        if ( tempImage )
            return [self initWithCGImage:[tempImage CGImage] scale:1.0 orientation:UIImageOrientationUp];
        
        newPath = [NSString stringWithFormat:@"%@@2x.png", path];
        tempImage = [UIImage imageNamed:newPath];
        if ( tempImage )
            return [self initWithCGImage:[tempImage CGImage] scale:1.0 orientation:UIImageOrientationUp];
    }
    
    newPath = [NSString stringWithFormat:@"%@@2x.png", path];
    tempImage = [UIImage imageNamed:newPath];
    if ( tempImage )
        return [self initWithCGImage:[tempImage CGImage] scale:2.0 orientation:UIImageOrientationUp];
    
    newPath = [NSString stringWithFormat:@"%@.png", path];
    tempImage = [UIImage imageNamed:newPath];
    if ( tempImage )
        return [self initWithCGImage:[tempImage CGImage] scale:2.0 orientation:UIImageOrientationUp];
    
    return nil;
}

+ (UIImage *)imageNamedUniversal:(NSString *)name
{
    return [[UIImage alloc] initWithContentsOfScalableFile:name];
}

@end
