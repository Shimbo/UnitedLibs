//
//  ULEventManager.h
//  Fuge
//
//  Created by Mikhail Larionov on 9/25/13.
//
//

#import <Foundation/Foundation.h>
#import "ULEvent.h"

#define eventManager [ULEventManager sharedInstance]

@interface ULEventManager : NSObject
{
    NSMutableArray      *events;
}

+ (ULEventManager*) sharedInstance;

// General
- (NSArray*) events;
- (id) eventById:(NSString*)strId;
- (Boolean) addEvent:(ULEvent*)event;

@end
