//
//  Meetup.m
//  SecondCircle
//
//  Created by Mikhail Larionov on 1/6/13.
//
//

#import "ULEvent.h"
#import "GlobalData.h"
#import "GlobalVariables.h"
#import "FSVenue.h"
#import "LocationManager.h"
#import "AppDelegate.h"
#import "PushManager.h"

@implementation ULEvent

/*@synthesize strOwnerId=_strOwnerId, strOwnerName=_strOwnerName, strSubject=_strSubject, strDescription=_strDescription, dateTime=_dateTime, privacy=_privacy, meetupType=_meetupType, venueString=_venueString, venueId=_venueId, venueAddress=_venueAddress, commentsCount=_commentsCount, attendees=_attendees, decliners=_decliners, durationSeconds=_durationSeconds, importedEvent=_importedEvent, importedType=_importedType, iconNumber=_iconNumber, strPrice=_strPrice, strImageURL=_strImageURL, strOriginalURL=_strOriginalURL, maxGuests=_maxGuests, canceled=_canceled;*/

-(id) init
{
    if (self = [super init]) {
        _meetupType = TYPE_MEETUP;
        _attendees = nil;
        _decliners = nil;
        _commentsCount = 0;
        _venueAddress = @"";
        _venueId = @"";
        _venueString = @"";
        _importedEvent = FALSE;
        _iconNumber = 0;
        _canceled = FALSE;
        _importedType = IMPORTED_NOT;
    }
    
    return self;
}

-(Boolean)hasPassed
{
    return [_dateTime compare:[NSDate dateWithTimeIntervalSinceNow:
                              -(NSTimeInterval)_durationSeconds]] == NSOrderedAscending;
}

-(Boolean)isWithinTimeFrame:(NSDate*)windowStart till:(NSDate*)windowEnd
{
    NSDate* dateEnds = [_dateTime dateByAddingTimeInterval:_durationSeconds];
    if ( [_dateTime compare:windowStart] == NSOrderedAscending &&
            [dateEnds compare:windowStart] == NSOrderedAscending )
        return false;
    if ( [_dateTime compare:windowEnd] == NSOrderedDescending &&
        [dateEnds compare:windowEnd] == NSOrderedDescending )
        return false;
    return true;
}

-(float)getTimerTill
{
    NSTimeInterval meetupInterval = [_dateTime timeIntervalSinceNow];
    
    if ( meetupInterval < 3600*12 && meetupInterval > - (float) _durationSeconds )
    {
        float fTimer = 1.0 - ( (float) ( meetupInterval ) ) / (3600.0f*12.0f);
        if ( fTimer > 1.0 )
            fTimer = 1.0f;
        if ( fTimer < 0.0 )
            fTimer = 0.0f;
        
        return fTimer;
    }
    
    return 0.0f;
}

- (void)presentEventEditViewControllerWithEventStore:(EKEventStore*)eventStore
{
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    event.title     = [_strSubject stringByAppendingFormat:@" at %@", _venueString];
    event.startDate = _dateTime;
    event.endDate   = [[NSDate alloc] initWithTimeInterval:_durationSeconds sinceDate:event.startDate];
    event.location  = _venueAddress;
    
    EKEventEditViewController* eventView = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    [eventView setEventStore:eventStore];
    [eventView setEvent:event];
    
    FugeAppDelegate *delegate = AppDelegate;
    UIViewController* controller = delegate.revealController;
    
    [controller presentViewController:eventView animated:YES completion:nil];
    
    eventView.editViewDelegate = self;
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
    
    NSError *error = nil;
    EKEvent *thisEvent = controller.event;
    
    switch (action) {
        case EKEventEditViewActionCanceled:
            break;
            
        case EKEventEditViewActionSaved:
            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            break;
            
        case EKEventEditViewActionDeleted:
            [controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
            break;
            
        default:
            break;
    }
    // Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
/*- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
 //EKCalendar *calendarForEdit = self.defaultCalendar;
 return calendarForEdit;
 }*/

- (void) addToCalendarInternal
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    // iOS 6 introduced a requirement where the app must
    // explicitly request access to the user's calendar. This
    // function is built to support the new iOS 6 requirement,
    // as well as earlier versions of the OS.
    if([eventStore respondsToSelector:
        @selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [eventStore
         requestAccessToEntityType:EKEntityTypeEvent
         completion:^(BOOL granted, NSError *error) {
             // If you don't perform your presentation logic on the
             // main thread, the app hangs for 10 - 15 seconds.
             [self performSelectorOnMainThread:
              @selector(presentEventEditViewControllerWithEventStore:)
                                    withObject:eventStore
                                 waitUntilDone:NO];
         }];
    } else {
        // iOS 5
        [self presentEventEditViewControllerWithEventStore:eventStore];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag == 1 )
    {
        // No
        if ( buttonIndex == 2 )
            return;
        
        // Always
        if ( buttonIndex == 0 )
            [globalVariables setToAlwaysAddToCalendar];
        
        // Yes
        [self addToCalendarInternal];
    }
}

-(void) addToCalendar
{
    // Already added
    if ( [self addedToCalendar] )
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Calendar" message:@"This meetup is already added to your calendar." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        message.tag = 1;
        [message show];
        return;
    }
    
    // Ask yes/no/always question
    if ( ! [globalVariables shouldAlwaysAddToCalendar] )
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Calendar" message:@"Would you like to add this event to your calendar?" delegate:self cancelButtonTitle:@"Always" otherButtonTitles:@"Yes",@"No",nil];
        [message show];
    }
    else
        [self addToCalendarInternal];
}

-(Boolean) addedToCalendar
{
    /*EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    NSDate* dateEnd = [[NSDate alloc] initWithTimeInterval:durationSeconds sinceDate:dateTime];
    NSPredicate *predicateForEvents = [eventStore predicateForEventsWithStartDate:dateTime endDate:dateEnd calendars:nil];
    
    NSArray *eventsFound = [eventStore eventsMatchingPredicate:predicateForEvents];
    
    for (EKEvent *eventToCheck in eventsFound)
    {
        if ([eventToCheck.location isEqualToString:strAddress])
            if ( [eventToCheck.title isEqualToString:[strSubject stringByAppendingFormat:@" at %@", strVenue]])
            return true;
    }*/
    
    return false;
}

-(Boolean)hasAttendee:(NSString*)str
{
    if ( ! _attendees )
        return FALSE;
    if ( [_attendees indexOfObject:str] == NSNotFound )
        return FALSE;
    return TRUE;
}

-(void)addAttendee:(NSString*)str
{
    if ( ! _attendees )
        _attendees = [[NSMutableArray alloc] initWithObjects:str, nil];
    else
    {
        [_attendees removeObjectIdenticalTo:str];
        [_attendees addObject:str];
    }
}

-(void)removeAttendee:(NSString*)str
{
    if ( _attendees )
        [_attendees removeObjectIdenticalTo:str];
}

-(Boolean)willStartSoon
{
    if ( [self isCanceled] )
        return FALSE;
    if ( [self hasPassed] )
        return FALSE;
    if ( self.meetupType != TYPE_MEETUP )
        return FALSE;
    
    if ( [self getTimerTill] > TIME_FOR_JOIN_PERSON_AND_MEETUP)
        return TRUE;
    return FALSE;
}

-(Boolean)isPersonNearby:(Person*)person
{
    CLLocation *loc1 = [[CLLocation alloc]initWithLatitude:person.location.latitude longitude:person.location.longitude];
    CLLocation *loc2 = [[CLLocation alloc]initWithLatitude:self.location.latitude longitude:self.location.longitude];
    if ([loc1 distanceFromLocation:loc2] < DISTANCE_FOR_JOIN_PERSON_AND_MEETUP) {
        return YES;
    }
    return NO;
}

-(NSInteger)spotsAvailable
{
    if ( ! self.maxGuests )
        return INT_MAX;
    NSInteger nSpots = [self.maxGuests integerValue] - (NSInteger)self.attendees.count;
    if ( nSpots < 0 ) nSpots = 0;
    return nSpots;
}

-(void)incrementCommentsCount
{
    _commentsCount++;
}

- (Boolean) feature:(NSString*)feature
{
    _featureString = feature;
    return TRUE;
}

@end
