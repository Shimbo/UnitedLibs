//
//  GeoObject.h
//  Fuge
//
//  Created by Mikhail Larionov on 8/4/13.
//
//

#import <Foundation/Foundation.h>

@interface ULGeoObject : NSObject {
    
    NSString    *_strId;
    PFGeoPoint  *_location;
}

@property (nonatomic, retain) NSString      *strId;
@property (nonatomic, retain) PFGeoPoint    *location;

- (NSNumber*)distance;
- (NSString*)distanceString:(Boolean)precise;

@end
