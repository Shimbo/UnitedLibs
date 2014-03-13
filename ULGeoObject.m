//
//  GeoObject.m
//  Fuge
//
//  Created by Mikhail Larionov on 8/4/13.
//
//

#import "ULGeoObject.h"
#import "ULLocationManager.h"

@implementation ULGeoObject

@synthesize strId = _strId, location = _location;

- (NSNumber*)distance
{
    // Distance calculation
    PFGeoPoint* geoPointUser = [locManager getPosition];
    
    if ( ! self.location || ! geoPointUser )
        return nil;
    
    return [NSNumber numberWithDouble:
                [geoPointUser distanceInKilometersTo:self.location]*1000.0f];
}

-(NSString*)distanceString:(Boolean)precise
{
    NSNumber* distance = [self distance];
    if ( ! distance )
        return @"";
    
    if ( [distance floatValue] < 100.0f ) {
        if ( precise )
            return [[NSString alloc] initWithFormat:@"%.0f m", [distance floatValue]];
        else
            return NSLocalizedString(@"USER_PROFILE_NEARBY",nil);
    }
    else if ( [distance floatValue] < 1000.0f )
            return [[NSString alloc] initWithFormat:@"%.0f m", [distance floatValue]];
    else if ( [distance floatValue] < 10000.0f )
        return [[NSString alloc] initWithFormat:@"%.1f km", [distance floatValue]/1000.0f];
    else
        return [[NSString alloc] initWithFormat:@"%.0f km", [distance floatValue]/1000.0f];
}


@end
