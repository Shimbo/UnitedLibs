//
//  Meetup.h
//  SecondCircle
//
//  Created by Mikhail Larionov on 1/6/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "ULGeoObject.h"

typedef enum kEMeetupType
{
    TYPE_THREAD     = 0,
    TYPE_MEETUP     = 1
} EMeetupType;

typedef enum kEMeetupPrivacy
{
    MEETUP_PUBLIC   = 0,
    MEETUP_PRIVATE  = 1
} EMeetupPrivacy;

@class Person;

@interface ULEvent : ULGeoObject <EKEventEditViewDelegate, UIAlertViewDelegate>
{
    EMeetupType     _meetupType;
    EMeetupPrivacy  _privacy;
    
    NSString    *_strOwnerId;
    NSString    *_strOwnerName;
    NSString    *_strSubject;
    NSString    *_strDescription;
    NSDate      *_dateTime;
    NSUInteger  _durationSeconds;
    NSDate      *_dateTimeExp;
    NSUInteger  _iconNumber;
    NSString    *_strPrice;
    NSNumber    *_maxGuests;
    NSString    *_strImageURL;
    NSString    *_strOriginalURL;
    NSString    *_strNotes;
    
    NSString    *_venueString;
    NSString    *_venueId;
    NSString    *_venueAddress;

    NSUInteger  _commentsCount;
    NSMutableArray* _attendees;
    NSMutableArray* _decliners;
    
    Boolean     _importedEvent;
    NSUInteger  _importedType;
    
    Boolean     _canceled;
    
    NSString *_featureString;
}

// Editable properties (upon creation)
/*@property (nonatomic, readonly) EMeetupType     meetupType;
@property (nonatomic, readonly) EMeetupPrivacy  privacy;
@property (nonatomic, readonly) NSString*       strOwnerId;
@property (nonatomic, readonly) NSString*       strOwnerName;
@property (nonatomic, readonly) NSString*       strSubject;
@property (nonatomic, readonly) NSString*       strDescription;
@property (nonatomic, readonly) NSDate*         dateTime;
@property (nonatomic, readonly) NSUInteger      durationSeconds;
@property (nonatomic, readonly) NSUInteger      iconNumber;
@property (nonatomic, readonly) NSString*       strPrice;
@property (nonatomic, readonly) NSNumber*       maxGuests;
@property (nonatomic, readonly) NSString*       strImageURL;
@property (nonatomic, readonly) NSString*       strOriginalURL;*/

@property (nonatomic, assign)   EMeetupType     meetupType;
@property (nonatomic, assign)   EMeetupPrivacy  privacy;
@property (nonatomic, retain)   NSString*   strOwnerId;
@property (nonatomic, retain)   NSString*   strOwnerName;
@property (nonatomic, retain)   NSString*   strSubject;
@property (nonatomic, retain)   NSString*   strDescription;
@property (nonatomic, retain)   NSDate*     dateTime;
@property (nonatomic, retain)   NSDate*     dateTimeExp;
@property (nonatomic, assign)   NSUInteger  durationSeconds;
@property (nonatomic, assign)   NSUInteger  iconNumber;
@property (nonatomic, retain)   NSString*   strPrice;
@property (nonatomic, retain)   NSNumber*   maxGuests;
@property (nonatomic, retain)   NSString*   strImageURL;
@property (nonatomic, retain)   NSString*   strOriginalURL;
@property (nonatomic, retain)   NSString*   strNotes;

// Venue data
@property (nonatomic, readonly) NSString *venueString;
@property (nonatomic, readonly) NSString *venueId;
@property (nonatomic, readonly) NSString *venueAddress;

// Misc data (TODO: move to FUGEvent?
@property (nonatomic, readonly) NSUInteger commentsCount;
@property (nonatomic, readonly) NSMutableArray* attendees;
@property (nonatomic, readonly) NSMutableArray* decliners;

// Import data
@property (nonatomic, readonly, getter=isImported) Boolean importedEvent;
@property (nonatomic, readonly) NSUInteger importedType;

// Canceled or not
@property (nonatomic, readonly, getter=isCanceled) Boolean canceled;

// Featured
@property (nonatomic, readonly) NSString *featureString;

// Initialization
-(id) init;

// Calendar
-(Boolean) addedToCalendar;
-(void) addToCalendar;

// Time operations
-(Boolean)hasPassed;
-(Boolean)isWithinTimeFrame:(NSDate*)windowStart till:(NSDate*)windowEnd;
-(float)getTimerTill;

// Only in local version, not on server (separate cloud code)
-(Boolean)hasAttendee:(NSString*)str;
-(void)addAttendee:(NSString*)str;
-(void)removeAttendee:(NSString*)str;

-(NSInteger)spotsAvailable;

-(Boolean)willStartSoon;
-(Boolean)isPersonNearby:(Person*)person;

-(void)incrementCommentsCount;

-(Boolean) feature:(NSString*)feature;

@end