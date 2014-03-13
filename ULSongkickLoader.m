//
//  ULSongkickLoader.m
//  United Libs
//
//  Created by Mikhail Larionov on 6/21/13.
//
//

#import "ULSongkickLoader.h"
#import "XMLDictionary.h"

@implementation ULSongkickLoader

#define TIMEOUT_INTERVAL 45


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *someString = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    //NSLog(@"Songkick results: %@", someString);
    
    NSError* error;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&error];
    if ( ! dict )
        return;
    if ( error )
        return; // TODO: return error
    NSDictionary* dict2 = [dict objectForKey:@"resultsPage"];
    NSDictionary* dict3 = [dict2 objectForKey:@"results"];
    
    if ( modeSingleEvent )
    {
        NSDictionary* event = [dict3 objectForKey:@"event"];
        [resultTarget performSelector:resultCallback withObject:event];
        return;
    }
    
    NSArray* tempArray = [dict3 objectForKey:@"event"];
    totalLoadedCount += tempArray.count;
    
    // Add only unique
    for ( NSDictionary* event in tempArray )
    {
        BOOL found = NO;
        for ( NSDictionary* oldEvent in eventsArray )
            if ( [[oldEvent objectForKey:@"id"] longValue] == [[event objectForKey:@"id"] longValue] )
            {
                found = YES;
                break;
            }
        
        BOOL farAway = NO;
        NSDictionary* location = [event objectForKey:@"location"];
        if ( ! location )
            farAway = YES;
        else
        {
            NSString* strLat = [location objectForKey:@"lat"];
            NSString* strLon = [location objectForKey:@"lng"];
            if ( ! strLat || ! strLon ||
                    (NSNull*)strLat == [NSNull null] || (NSNull*)strLon == [NSNull null] )
                farAway = YES;
            else
            {
                double lat = [strLat doubleValue];
                double lon = [strLon doubleValue];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                if ( [location distanceFromLocation:coordinates] > SONGKICK_MAX_DISTANCE )
                    farAway = YES;
            }
        }
        
        if ( ! found && ! farAway )
            [eventsArray addObject:event];
    }
    //[eventsArray addObjectsFromArray:tempArray];
    
    NSString* stringTotalEntries = [dict2 objectForKey:@"totalEntries"];
    NSUInteger totalEntries = [stringTotalEntries integerValue];
    if ( totalLoadedCount >= totalEntries || eventsArray.count >= SONGKICK_MAX_EVENTS )
    {
        Boolean bBadEventFound;
        do {
            bBadEventFound = false;
            for ( NSDictionary* event in eventsArray )
            {
                NSDictionary* location = [event objectForKey:@"location"];
                NSString* strLat = [location objectForKey:@"lat"];
                NSString* strLon = [location objectForKey:@"lng"];
                if ( ! strLat || ! strLon || strLat == (id)[NSNull null] || strLon == (id)[NSNull null] )
                    bBadEventFound = true;
                else
                {
                    //double lat = [strLat doubleValue];
                    //double lon = [strLon doubleValue];
                    
                    //CLLocation* location1 = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
                    //CLLocation* location2 = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                    //CLLocationDistance distance = [location1 distanceFromLocation:location2];
                    //if ( distance > SONGKICK_DISCOVERY_DISTANCE )
                    //    bBadEventFound = true;
                }
                if ( bBadEventFound )
                {
                    [eventsArray removeObject:event];
                    break;
                }
            }
        } while ( bBadEventFound );
        
        if ( currentPeriod < maxPeriod && eventsArray.count < SONGKICK_MAX_EVENTS )
        {
            // Increment period
            previousPeriod = currentPeriod;
            if ( currentPeriod == SONGKICK_PERIOD_STEP1 )
                currentPeriod = SONGKICK_PERIOD_STEP2;
            else if ( currentPeriod == SONGKICK_PERIOD_STEP2 )
                currentPeriod = SONGKICK_PERIOD_STEP3;
            else if ( currentPeriod == SONGKICK_PERIOD_STEP3 )
                currentPeriod = maxPeriod;
            page = 1;
            totalLoadedCount = 0;
            [self loadDataInternal];
        }
        else
            [resultTarget performSelector:resultCallback withObject:eventsArray];
    }
    else
    {
        page++;
        [self loadDataInternal];
    }
}

- (void)loadData:(CLLocationCoordinate2D)coords forPeriod:(NSUInteger)days target:(id)target selector:(SEL)callback
{
    modeSingleEvent = false;
    
    resultTarget = target;
    resultCallback = callback;
    eventsArray = [NSMutableArray arrayWithCapacity:SONGKICK_MAX_EVENTS];
    page = 1;
    totalLoadedCount = 0;
    coordinates = [[CLLocation alloc] initWithLatitude:coords.latitude longitude:coords.longitude];
    maxPeriod = days;
    previousPeriod = 0;
    if ( maxPeriod > SONGKICK_PERIOD_STEP1 )
        currentPeriod = SONGKICK_PERIOD_STEP1;
    else if ( maxPeriod > SONGKICK_PERIOD_STEP2 )
        currentPeriod = SONGKICK_PERIOD_STEP2;
    else if ( maxPeriod > SONGKICK_PERIOD_STEP3 )
        currentPeriod = SONGKICK_PERIOD_STEP3;
    else
        currentPeriod = maxPeriod;
    
    [self loadDataInternal];
}

- (void)loadDataInternal
{
    receivedData = [NSMutableData data];
    
    NSDateFormatter* theDateFormatter = [[NSDateFormatter alloc] init];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [theDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* dayNow = [NSDate dateWithTimeIntervalSinceNow:86400*previousPeriod];
    NSDate* dayThen = [NSDate dateWithTimeIntervalSinceNow:86400*currentPeriod];
    NSString *stringDayNow = [theDateFormatter stringFromDate:dayNow];
    NSString *stringDayThen = [theDateFormatter stringFromDate:dayThen];
    
    NSString* strRequest = [NSString stringWithFormat:@"http://api.songkick.com/api/3.0/events.json?apikey=%@&location=geo:%f,%f&min_date=%@&max_date=%@&page=%d", SONGKICK_API_KEY, coordinates.coordinate.latitude, coordinates.coordinate.longitude, stringDayNow, stringDayThen, page];
    NSURL* urlRequest = [NSURL URLWithString:strRequest];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:TIMEOUT_INTERVAL];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (! connection)
        NSLog(@"Failed to establish Songkick connection");
}

- (void)loadEvent:(NSString*)eventId target:(id)target selector:(SEL)callback
{
    modeSingleEvent = true;
    
    resultTarget = target;
    resultCallback = callback;
    receivedData = [NSMutableData data];
    eventsArray = [NSMutableArray arrayWithCapacity:100];
    page = 1;
    
    NSString* strRequest = [NSString stringWithFormat:@"http://api.songkick.com/api/3.0/events/%@.json?apikey=%@", eventId, SONGKICK_API_KEY];
    NSURL* urlRequest = [NSURL URLWithString:strRequest];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:TIMEOUT_INTERVAL];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (! connection)
        NSLog(@"Failed to establish Songkick connection");

}

@end
