//
//  ULSongkickLoader.h
//  United Libs
//
//  Created by Mikhail Larionov on 6/21/13.
//
//

#import <Foundation/Foundation.h>

#define SONGKICK_MAX_EVENTS             250
#define SONGKICK_MAX_DISTANCE           30000   // meters
#define SONGKICK_PERIOD_STEP1           2
#define SONGKICK_PERIOD_STEP2           6
#define SONGKICK_PERIOD_STEP3           14

@interface ULSongkickLoader : NSObject <NSURLConnectionDelegate>
{
    Boolean modeSingleEvent;
    
    NSUInteger currentPeriod;
    NSUInteger previousPeriod;
    NSUInteger maxPeriod;
    id resultTarget;
    SEL resultCallback;
    NSMutableData* receivedData;
    NSMutableArray* eventsArray;
    NSUInteger page;
    CLLocation *coordinates;
    NSUInteger totalLoadedCount;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)loadData:(CLLocationCoordinate2D)coords forPeriod:(NSUInteger)days target:(id)target selector:(SEL)callback;
- (void)loadEvent:(NSString*)eventId target:(id)target selector:(SEL)callback;

@end
