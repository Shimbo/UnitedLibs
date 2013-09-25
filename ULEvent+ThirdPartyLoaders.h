//
//  ULEvent+ThirdPartyLoaders.h
//  Fuge
//
//  Created by Mikhail Larionov on 9/25/13.
//
//

#import "ULEvent.h"

@interface ULEvent (ThirdPartyLoaders)

-(id) initWithFacebookEvent:(NSDictionary*)data;
-(id) initWithEventbriteEvent:(NSDictionary*)data;
-(id) initWithMeetupEvent:(NSDictionary*)data;

@end