//
//  ULEvent+ThirdPartyLoaders.m
//  Fuge
//
//  Created by Mikhail Larionov on 9/25/13.
//
//

#import "ULEvent+ThirdPartyLoaders.h"

@implementation ULEvent (ThirdPartyLoaders)

-(id) initWithFacebookEvent:(NSDictionary*)data
{
    self = [self init];
    
    NSDictionary* eventData = [data objectForKey:@"event"];
    if ( ! eventData )
        return nil;
    NSDictionary* venueData = [data objectForKey:@"venue"];
    if ( ! venueData )
        return nil;
    
    _importedEvent = true;
    _importedType = IMPORTED_FACEBOOK;
    _meetupType = TYPE_MEETUP;
    _privacy = MEETUP_PUBLIC;
    
    _strId = [NSString stringWithFormat:@"fbmt_%@", [eventData objectForKey:@"eid"]];
    _strOwnerId = [eventData objectForKey:@"creator"];
    _strOwnerName = [eventData objectForKey:@"host"];
    _strSubject = [eventData objectForKey:@"name"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSString* strStartDate = [eventData objectForKey:@"start_time"];
    if ( ! strStartDate || ! [strStartDate isKindOfClass:[NSString class]] )
        return nil;
    _dateTime = [dateFormatter dateFromString:strStartDate];
    NSString* strEndDate = [eventData objectForKey:@"end_time"];
    if ( strEndDate && [strEndDate isKindOfClass:[NSString class]] )
    {
        NSDate* endDate = [dateFormatter dateFromString:strEndDate];
        _durationSeconds = [endDate timeIntervalSince1970] - [_dateTime timeIntervalSince1970];
        _dateTimeExp = endDate;
    }
    else
    {
        _durationSeconds = 3600;
        _dateTimeExp = [_dateTime dateByAddingTimeInterval:_durationSeconds];
    }
    
    NSDictionary* venueLocation = [venueData objectForKey:@"location"];
    if ( ! [venueLocation objectForKey:@"latitude"] || ! [venueLocation objectForKey:@"longitude"])
        return nil;
    double lat = [[venueLocation objectForKey:@"latitude"] doubleValue];
    double lon = [[venueLocation objectForKey:@"longitude"] doubleValue];
    _location = [PFGeoPoint geoPointWithLatitude:lat longitude:lon];
    _venueString = [venueLocation objectForKey:@"name"];
    if ( ! _venueString )
        _venueString = [venueData objectForKey:@"name"];
    _venueAddress = [venueLocation objectForKey:@"street"];
    
    _attendees = [NSMutableArray arrayWithObject:strCurrentUserId];
    
    return self;
}

-(id) initWithEventbriteEvent:(NSDictionary*)data
{
    self = [self init];
    
    _importedType = false;
    _importedType = IMPORTED_EVENTBRITE;
    _meetupType = TYPE_MEETUP;
    _privacy = MEETUP_PUBLIC;
    
    _strId = [ [NSString alloc] initWithFormat:@"ebmt_%@", [data objectForKey:@"id"]];
    _strOwnerId = @"";
    
    NSDictionary* organizer = [data objectForKey:@"organizer"];
    if ( organizer )
    {
        if ( [organizer objectForKey:@"name"] )
            _strOwnerName = [organizer objectForKey:@"name"];
    }
    else
        _strOwnerName = @"Unknown";
    if ( ! [data objectForKey:@"title"] || ! [[data objectForKey:@"title"] isKindOfClass:[NSString class]] )
        return nil;
    _strSubject = [[data objectForKey:@"title"] capitalizedString];
    if ( [data objectForKey:@"description"] )
        _strDescription = [data objectForKey:@"description"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* strStartDate = [data objectForKey:@"start_date"];
    if ( ! strStartDate || ! [strStartDate isKindOfClass:[NSString class]] )
        return nil;
    _dateTime = [dateFormatter dateFromString:strStartDate];
    if ( ! _dateTime )
        return nil;
    NSString* strEndDate = [data objectForKey:@"end_date"];
    if ( ! strEndDate )
        return nil;
    NSDate* endDate = [dateFormatter dateFromString:strEndDate];
    if ( ! endDate )
        return nil;
    // CHANGE THIS if you'd like to load old events!
    if ( [endDate compare:[NSDate date]] == NSOrderedAscending )
        return nil;
    _durationSeconds = [endDate timeIntervalSince1970] - [_dateTime timeIntervalSince1970];
    if ( _durationSeconds > 3600*24*3 )  // Exclude events more than tree days in duration
        return nil;
    _dateTimeExp = endDate;
    
    NSDictionary* venue = [data objectForKey:@"venue"];
    if ( ! venue )
        return nil;
    if ( ! [venue objectForKey:@"Lat-Long"] )
        return nil;
    
    NSString* strLat = [venue objectForKey:@"latitude"];
    NSString* strLon = [venue objectForKey:@"longitude"];
    if ( ! strLat || ! strLon )
        return nil;
    
    double lat = [strLat doubleValue];
    double lon = [strLon doubleValue];
    _location = [PFGeoPoint geoPointWithLatitude:lat longitude:lon];
    
    _venueString = [venue objectForKey:@"name"];
    if ( ! _venueString || ! [_venueString isKindOfClass:[NSString class]] )
        _venueString = [venue objectForKey:@"Lat-Long"];
    _venueAddress = [venue objectForKey:@"address"];
    
    NSDictionary* ticketsDict = [data objectForKey:@"tickets"];
    NSArray* tickets = [ticketsDict objectForKey:@"ticket"];
    if ( [tickets isKindOfClass:[NSDictionary class]] ) // Evenbrite, my ass...
        tickets = [NSArray arrayWithObject:tickets];
    NSNumber *minPrice = nil, *maxPrice = nil;
    NSString* strCurrency = nil;
    Boolean atLeastOneTicketAvailable = false;
    for ( NSDictionary* ticket in tickets )
    {
        strEndDate = [ticket objectForKey:@"end_date"];
        if ( strEndDate && [strEndDate isKindOfClass:[NSString class]] )
        {
            endDate = [dateFormatter dateFromString:strEndDate];
            if ( [endDate compare:[NSDate date]] == NSOrderedDescending )
                atLeastOneTicketAvailable = true;
        }
        
        NSNumber* price = [ticket objectForKey:@"price"];
        
        if ( ! price )
            continue;
        
        if ( ! minPrice || [price floatValue] < [minPrice floatValue] )
            minPrice = price;
        
        if ( ! maxPrice || [price floatValue] > [maxPrice floatValue] )
            maxPrice = price;
        
        strCurrency = [ticket objectForKey:@"currency"];
    }
    if ( minPrice && maxPrice && [minPrice floatValue] != [maxPrice floatValue] )
        _strPrice = [NSString stringWithFormat:@"%.2f to %.2f %@", [minPrice floatValue], [maxPrice floatValue], strCurrency ? strCurrency : @""];
    else if ( minPrice && [minPrice floatValue] == 0.0f )
        _strPrice = nil;
    else if ( minPrice )
        _strPrice = [NSString stringWithFormat:@"%.2f %@", [minPrice floatValue], strCurrency ? strCurrency : @""];
    
    if ( ! atLeastOneTicketAvailable )
        _maxGuests = [NSNumber numberWithInteger:0];
    
    _strOriginalURL = [data objectForKey:@"url"];
    
    return self;
}

-(id) initWithMeetupEvent:(NSDictionary*)data
{
    self = [self init];
    
    _importedType = IMPORTED_MEETUP;
    _meetupType = TYPE_MEETUP;
    _privacy = MEETUP_PUBLIC;
    
    _strId = [ [NSString alloc] initWithFormat:@"mtmt_%@", [data objectForKey:@"id"]];
    _strOwnerId = strCurrentUserId;
    
    NSDictionary* organizer = [data objectForKey:@"group"];
    if ( organizer )
    {
        if ( [organizer objectForKey:@"name"] )
            _strOwnerName = [organizer objectForKey:@"name"];
    }
    else
        _strOwnerName = @"Unknown";
    if ( [data objectForKey:@"name"] )
        _strSubject = [data objectForKey:@"name"];
    else
        _strSubject = @"Unknown";
    
    // Description and how-to-find
    NSMutableString* description = nil;
    NSUInteger nYesRSVPs = 0;
    if ( [data objectForKey:@"yes_rsvp_count"] )
        nYesRSVPs = [[data objectForKey:@"yes_rsvp_count"] integerValue];
    if ( [data objectForKey:@"rsvp_limit"] )
        _maxGuests = [NSNumber numberWithInteger:[[data objectForKey:@"rsvp_limit"] integerValue] - nYesRSVPs];
    if ( [data objectForKey:@"description"] )
    {
        description = [data objectForKey:@"description"];
        if ( nYesRSVPs > 0 )
            [description insertString:[NSString stringWithFormat:@"Meetup.com attendees: %d<BR>", nYesRSVPs] atIndex:0];
        if ( [data objectForKey:@"how_to_find_us"] )
            [description insertString:[NSString stringWithFormat:@"How to find: %@<BR>", [data objectForKey:@"how_to_find_us"]] atIndex:0];
    }
    _strDescription = description;
    
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* strStartDate = [data objectForKey:@"time"];
    if ( ! strStartDate )
        return nil;
    NSTimeInterval timeInterval = [strStartDate longLongValue];
    timeInterval /= 1000;
    _dateTime = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    if ( ! _dateTime )
        return nil;
    
    NSString* strDuration = [data objectForKey:@"duration"];
    if ( strDuration )
    {
        _durationSeconds = [strDuration integerValue] / 1000;
        if ( _durationSeconds > 3600*24*3 )  // Exclude events more than tree days in duration
            return nil;
    }
    else
        _durationSeconds = 3600*3;
    _dateTimeExp = [_dateTime dateByAddingTimeInterval:_durationSeconds];
    
    NSDictionary* venue = [data objectForKey:@"venue"];
    if ( ! venue )
        return nil;
    
    NSString* strLat = [venue objectForKey:@"lat"];
    NSString* strLon = [venue objectForKey:@"lon"];
    if ( ! strLat || ! strLon )
        return nil;
    
    double lat = [strLat doubleValue];
    double lon = [strLon doubleValue];
    _location = [PFGeoPoint geoPointWithLatitude:lat longitude:lon];
    
    _venueString = [venue objectForKey:@"name"];
    if ( ! _venueString || ! [_venueString isKindOfClass:[NSString class]] )
        _venueString = [NSString stringWithFormat:@"%f : %f", lat, lon];
    if ( [venue objectForKey:@"address_1"] )
    {
        NSMutableString* address = [venue objectForKey:@"address_1"];
        if ( [venue objectForKey:@"city"] )
        {
            [address appendString:@", "];
            [address appendString:[venue objectForKey:@"city"]];
        }
        if ( [venue objectForKey:@"address_2"] )
        {
            [address appendString:@", "];
            [address appendString:[venue objectForKey:@"address_2"]];
        }
        _venueAddress = address;
    }
    
    NSDictionary* feeInfo = [data objectForKey:@"fee"];
    if ( feeInfo )
    {
        NSMutableString* price = [feeInfo objectForKey:@"amount"];
        if ( [feeInfo objectForKey:@"currency"] )
        {
            [price appendString:@" "];
            [price appendString:[feeInfo objectForKey:@"currency"]];
        }
        _strPrice = price;
    }
    
    _strOriginalURL = [data objectForKey:@"event_url"];
    
    return self;
}

@end
