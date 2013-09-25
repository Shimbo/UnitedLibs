//
//  ULEventManager.m
//  Fuge
//
//  Created by Mikhail Larionov on 9/25/13.
//
//

#import "ULEventManager.h"

@implementation ULEventManager

#pragma mark -
#pragma mark Singleton

static ULEventManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (ULEventManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        events = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark -
#pragma mark General

- (NSArray*) events;
{
    return events;
}

- (id) eventById:(NSString*)strId
{
    for (ULEvent* event in events)
        if ( [event.strId compare:strId] == NSOrderedSame )
            return event;
    return nil;
}

- (Boolean) addEvent:(ULEvent*)event
{
    if ( ! event )
        return false;
    
    // Update if added
    ULEvent* oldVersion = [self eventById:event.strId ];
    if ( oldVersion )
        [events removeObject:oldVersion];
    
    [events addObject:event];
    
    return true;
}

#pragma mark -
#pragma mark Event management

@end
