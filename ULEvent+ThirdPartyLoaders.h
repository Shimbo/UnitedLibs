//
//  ULEvent+ThirdPartyLoaders.h
//  Fuge
//
//  Created by Mikhail Larionov on 9/25/13.
//
//

#import "ULEvent.h"

typedef enum kEImportedType
{
    IMPORTED_NOT        = 0,
    IMPORTED_FACEBOOK   = 1,
    IMPORTED_EVENTBRITE = 2,
    IMPORTED_MEETUP     = 3,
    IMPORTED_SONGKICK   = 4
} EImportedType;

@interface ULEvent (ThirdPartyLoaders)

-(id) initWithFacebookEvent:(NSDictionary*)data;
-(id) initWithEventbriteEvent:(NSDictionary*)data;
-(id) initWithMeetupEvent:(NSDictionary*)data;
-(id) initWithSongkickEvent:(NSDictionary*)data;

+(NSUInteger) eventImportedTypeById:(NSString*)eventId;
+(NSString*) eventPlatformIdFromId:(NSString*)eventId;

@end