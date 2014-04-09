
//
//  ULUIDefs.h
//  United Libraries
//
//  Created by Mikhail Larionov on 1/01/14.
//
//

#import <Foundation/Foundation.h>

#define IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#define DEVICE_IS_IPHONE_5 ([UIScreen mainScreen].bounds.size.height == 568.f)

#define RETINA_MODE                                                     \
([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1)

#define SYSTEM_VERSION_IS_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define IOS_NEWER_OR_EQUAL_TO_7 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 7.0 )

CG_INLINE float vectorLength(CGPoint p) { return sqrt(p.x * p.x + p.y * p.y); }
CG_INLINE float vectorDistance(CGPoint p1,CGPoint p2) {
    return sqrtf((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y)); }

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define KEYBOARD_HEIGHT 216.f

@interface NSObject (PerformBlockAfterDelay)

- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block;

@end


@interface UIColor (HexColor)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end


@interface UIView (Coordinates)

@property (nonatomic) CGFloat originX;
@property (nonatomic) CGFloat originY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGSize size;

@end

@interface UIView (Localize)
-(void)localize;
@end


@interface UILabel (Copy) <NSCopying>

@end

@interface UINavigationController (Transition)

- (UIViewController*) replaceViewController:(UIViewController*)controller;

@end

@interface UIImage (iPadSupport)

- (id)initWithContentsOfScalableFile:(NSString *)path;
+ (UIImage *)imageNamedUniversal:(NSString *)name;

@end

#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                    \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")     \
code;                                                                   \
_Pragma("clang diagnostic pop")                                         \

#define UNI_COEF (IPAD ? 2.0 : 1.0)
#define UNI_POINT(p) (IPAD ? CGPointMake(p.x*2, p.y*2) : p)
#define UNI_REPOINT(p) (p = UNI_POINT(p))
#define UNI_SIZE(s) (IPAD ? CGSizeMake(s.width*2, s.height*2) : s)
#define UNI_RESIZE(s) (s = UNI_SIZE(s))
#define UNI_RECT(r) (IPAD ? CGRectMake(r.origin.x*2, r.origin.y*2, r.size.width*2, r.size.height*2) : r)
#define UNI_RERECT(r) (r = UNI_RECT(r))
#define UNI_REPOSITION_IPAD(r, d) (r = CGRectRepositionIPad(r, d, FALSE))
#define UNI_SHIFT_IPAD(r, d) (r = CGRectRepositionIPad(r, d, TRUE))
#define UNI_UPDATE_FONT(l) ([l setFont:[l.font fontWithSize:l.font.pointSize*UNI_COEF]])

typedef enum UniReposition
{
    REPOSITION_CENTER   = 0,
    REPOSITION_LEFT     = 1,
    REPOSITION_RIGHT    = 2,
    REPOSITION_TOP      = 3,
    REPOSITION_BOTTOM   = 4,
    REPOSITION_TOPLEFT     = 5,
    REPOSITION_TOPRIGHT    = 6,
    REPOSITION_BOTTOMLEFT  = 7,
    REPOSITION_BOTTOMRIGHT = 8

} LFCUniReposition;

CG_INLINE CGRect
CGRectRepositionIPad(CGRect r, NSUInteger direction, BOOL shift)
{
    CGRect res = CGRectMake(r.origin.x, r.origin.y, r.size.width*2.0, r.size.height*2.0 );
    if ( shift )
    {
        res.origin.x *= 2.0;
        res.origin.y *= 2.0;
    }
    
    if ( direction == REPOSITION_CENTER )
    {
        res.origin.x -= res.size.width/4;
        res.origin.y -= res.size.height/4;
    }
    
    if ( direction == REPOSITION_TOP )
        res.origin.x -= res.size.width/4;
    
    if ( direction == REPOSITION_BOTTOM )
    {
        res.origin.x -= res.size.width/4;
        res.origin.y -= res.size.height/2;
    }
    
    if ( direction == REPOSITION_LEFT )
        res.origin.y -= res.size.width/4;
    
    if ( direction == REPOSITION_RIGHT )
    {
        res.origin.x -= res.size.width/2;
        res.origin.y -= res.size.height/4;
    }
    
    if ( direction == REPOSITION_TOPLEFT ) {}
    
    if ( direction == REPOSITION_TOPRIGHT )
        res.origin.x -= res.size.width/2;
    
    if ( direction == REPOSITION_BOTTOMLEFT )
        res.origin.y -= res.size.height/2;
    
    if ( direction == REPOSITION_BOTTOMRIGHT )
    {
        res.origin.x -= res.size.width/2;
        res.origin.y -= res.size.height/2;
    }
    
    return res;
}

CG_INLINE CGPoint
CGPointMakeUni(CGFloat x, CGFloat y)
{
    float coef = UNI_COEF;
    CGPoint p; p.x = x * coef; p.y = y * coef; return p;
}

CG_INLINE CGSize
CGSizeMakeUni(CGFloat width, CGFloat height)
{
    float coef = UNI_COEF;
    CGSize size; size.width = width * coef; size.height = height * coef; return size;
}

CG_INLINE CGRect
CGRectMakeUni(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    float coef = UNI_COEF;
    CGRect rect;
    rect.origin.x = x * coef; rect.origin.y = y * coef;
    rect.size.width = width * coef; rect.size.height = height * coef;
    return rect;
}

CG_INLINE CGAffineTransform CGAffineTransformMakeRotationAt(CGFloat angle, CGPoint pt){
    const CGFloat fx = pt.x;
    const CGFloat fy = pt.y;
    const CGFloat fcos = cos(angle);
    const CGFloat fsin = sin(angle);
    return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos);
}

static inline void LFCSetObjectForKey(NSObject* objectTo, id object, NSString* key)
{
    if ([objectTo isKindOfClass:[NSCoder class]])
    {
        NSCoder* coder = (NSCoder*) objectTo;
        [coder encodeObject:object forKey:key];
    }
#ifdef PARSE_VERSION
    if ([objectTo isKindOfClass:[PFUser class]])
    {
        PFUser* user = (PFUser*) objectTo;
        [user setObject:object forKey:key];
    }
#endif
}

static inline id LFCObjectForKey(NSObject* objectFrom, NSString* key)
{
    if ([objectFrom isKindOfClass:[NSCoder class]])
    {
        NSCoder* coder = (NSCoder*) objectFrom;
        return [coder decodeObjectForKey:key];
    }
#ifdef PARSE_VERSION
    if ([objectFrom isKindOfClass:[PFUser class]])
    {
        PFUser* user = (PFUser*) objectFrom;
        return [user objectForKey:key];
    }
#endif
    return nil;
}

static inline NSUInteger ULEstimateTextHeightForTextView(NSString* text, UITextView* textView)
{
        // Height
    CGSize newSize;
    if ( IOS_NEWER_OR_EQUAL_TO_7 )
    {
        CGRect paragraphRect = [text boundingRectWithSize:CGSizeMake(textView.width-textView.textContainer.lineFragmentPadding*2, 9999) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:textView.font} context:nil];
        newSize = paragraphRect.size;
    }
    else
        newSize = [text sizeWithFont:textView.font constrainedToSize:CGSizeMake(textView.width, CGFLOAT_MAX)];
        
    CGFloat adj = ceilf(textView.font.ascender - textView.font.capHeight);
    CGFloat insets = 26;
    if ( IOS_NEWER_OR_EQUAL_TO_7 )
        insets = textView.textContainerInset.top + textView.textContainerInset.bottom;
    return floorf(newSize.height)+adj+insets;
}

static inline NSString* ULTimePassedWithDateString(NSDate* date)
{
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:date];
    if ( timePassed < 60.0 )
        return @"Few seconds ago";
    if ( timePassed < 3600.0 )
        return [NSString stringWithFormat:@"%d minutes ago", (int)(timePassed/60)];
    if ( timePassed < 86400.0 )
        return [NSString stringWithFormat:@"%d hours ago", (int)(timePassed/3660)];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDoesRelativeDateFormatting:TRUE];
    return [formatter stringFromDate:date];
}

static inline NSString* ULDistanceStringForDistance(double distance)
{
    if ( distance < 100 )
        return @"Right here";
    if ( distance < 1000 )
        return [NSString stringWithFormat:@"%dm away", (int)(distance/10)*10];
    if ( distance < 10000)
        return [NSString stringWithFormat:@"%.1fkm away", distance/1000.0];
    if ( distance < 100000)
        return [NSString stringWithFormat:@"%dkm away", (int)(distance/1000)];
    if ( distance < 1000000)
        return [NSString stringWithFormat:@"%dkm away", (int)(distance/10000)*10];
    return [NSString stringWithFormat:@"%dkm away", (int)(distance/100000)*100];
}

static inline UIImage* screenshot()
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
