//
//  EventMapModel.m
//  EventMap
//
//  Created by Emanuel Azage on 4/30/16.
//  Email: eazage@usc.edu
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

#import "EventMapModel.h"
#import "AFNetworking.h"
#import "MapViewController.h"


@interface EventMapModel () <CLLocationManagerDelegate>
@property (nonatomic, strong) NSMutableArray* mapAnnotations;
@property (nonatomic, strong) NSMutableArray* usersEvents;
@property (nonatomic,strong) EventAnnotation* selectedAnnotation;
@property (strong, nonatomic) NSString* eventsFilePath;
@property (weak, nonatomic) MapViewController* mapViewController;
@end

@implementation EventMapModel

+(instancetype) sharedModel{
    static EventMapModel *_sharedModel = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _usersEvents = [[NSMutableArray alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        _eventsFilePath = [documentsDirectory stringByAppendingPathComponent:kEventsPList];
        
        _usersEvents = [NSMutableArray arrayWithContentsOfFile:_eventsFilePath];
        
        // get list of userEvents from plist if plist exists
        if(!_usersEvents){
            NSArray* storedEvents = [[NSUserDefaults standardUserDefaults] objectForKey: kEventsArrayKey];
            
            if(storedEvents){
                _usersEvents = [storedEvents mutableCopy];
            } else {
                
                // initialize our events dictionaries for the user
                _usersEvents = [[NSMutableArray alloc] init];
            }
        }
        
        // initialize the list of annotations
        _mapAnnotations = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}


/* need a reference to the map view controller so I can let it know when the annotations have been 
    recieved from ticket master, threading/timing issue workaround
*/
-(void) setMapViewController:(MapViewController *)mapViewController{
    _mapViewController = mapViewController;
}

-(EventAnnotation*) getSelectedAnnotation{
    return self.selectedAnnotation;
}

-(void) setSelectedAnnotation:(EventAnnotation*) annotation{
    
    // need to make a copy since the annotion object is nil when the annotation is not being displayed
    EventAnnotation* ann = [[EventAnnotation alloc] initWithLat:annotation.lat lon:annotation.lon eventName:annotation.eventName eventLocationName:annotation.eventLocationName eventAddress:annotation.eventAddress eventDate:annotation.eventDate eventTime:annotation.eventTime];
    
    _selectedAnnotation = ann;
    
}

-(NSMutableArray*) getAnnotations{
    return self.mapAnnotations;
}

-(NSMutableArray*) getUserEvents{
    return self.usersEvents;
}

-(NSUInteger) getNumberOfUserEvents{
    return [self.usersEvents count];
}

-(NSString*) getUserEventNameAtIndex: (NSUInteger) index{
    return [self.usersEvents objectAtIndex:index][kEventName];
}

-(Boolean) isInUsersList: (EventAnnotation*) annotation{
    for(NSMutableDictionary* event in self.usersEvents){
        
        if([event[kEventName] isEqual:annotation.eventName]
           && [event[kEventLocationName] isEqual:annotation.eventLocationName]
           && [event[kEventAddress] isEqual:annotation.eventAddress]
           && [event[kEventDate] isEqual:annotation.eventDate]
           && [event[kEventTime] isEqual:annotation.eventTime]
           && [event[kLatitude] isEqual:[NSString stringWithFormat:@"%f", annotation.lat]]
           && [event[kLongitude] isEqual:[NSString stringWithFormat:@"%f", annotation.lon]]){
            
            return YES;
        }
    }
    
    return NO;
}

-(void) addEventToUsersList: (EventAnnotation*) eventAnn{
    NSMutableDictionary* event = [[NSMutableDictionary alloc] initWithObjectsAndKeys:eventAnn.eventName, kEventName, eventAnn.eventLocationName, kEventLocationName, eventAnn.eventAddress, kEventAddress, eventAnn.eventDate, kEventDate, eventAnn.eventTime, kEventTime, [NSString stringWithFormat:@"%f",eventAnn.lat], kLatitude, [NSString stringWithFormat:@"%f",eventAnn.lon], kLongitude, nil];
    
    [self.usersEvents addObject:event];
    [self saveUsersEvents];
}

-(void) removeUserEventAtIndex:(NSUInteger)index{
    [self.usersEvents removeObjectAtIndex:index];
    [self saveUsersEvents];
}

-(void) saveUsersEvents{
    [self.usersEvents writeToFile:self.eventsFilePath atomically:YES];
}

-(void)updateMap{
    [self getEventsForLat:self.lastUserLoc.coordinate.latitude
                     Long:self.lastUserLoc.coordinate.longitude];
}

#pragma AFNetworking method

// use AFNetworking to get events list from Tickets Master API then converts TM events into my own
// data object. Will notify mapController when events have all arrived and been converted
-(void) getEventsForLat: (double)lat Long: (double)lon{
//    NSLog(@"called AFNetworking method");
    
    NSString* const BaseURLString = @"https://app.ticketmaster.com/discovery/v2/events.json?apikey=EYrCGarBq3jz3ZHyxx2VTP6IA0J0QGuG";
    
    NSString* latlong = [[NSString alloc] initWithFormat:@"%f,%f", lat, lon];
    
    int numDaysUntilEndate;
    if(_numDaysForEvents){
        numDaysUntilEndate = [self numDaysForEvents];
    } else {
        numDaysUntilEndate = 14; // default amount
    }
    
    NSString* radiusForEvents;
    if(_radiusForEvents){
        radiusForEvents = [NSString stringWithFormat:@"%i", [self radiusForEvents]];
    } else{
        radiusForEvents = @"10";
    }
    
    NSString* maxNumForEvents;
    if(_maxNumForEvents){
        maxNumForEvents = [NSString stringWithFormat:@"%i", [self maxNumForEvents]];
    } else{
        maxNumForEvents = @"100";
    }

    
    NSTimeInterval MY_EXTRA_TIME = 60*60*24*numDaysUntilEndate;
    NSDate *futureDate = [[NSDate date] dateByAddingTimeInterval:MY_EXTRA_TIME];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:futureDate];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:futureDate];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:futureDate];
    NSString* endDate = [[NSString alloc] initWithFormat:@"%@-%@-%@T00:00:00Z", year, month, day];
   
    NSDictionary *parameters = @{ @"latlong":latlong, @"radius":radiusForEvents, @"unit":@"miles",
                                  @"source":@"ticketmaster", @"endDateTime":endDate, @"size":maxNumForEvents};
    
    // create AFNetworking manager class and get the annotations from TicketMaster
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:BaseURLString parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary* myData = (NSDictionary *)responseObject;
        NSDictionary *embedded = myData[@"_embedded"];
        if (embedded) {
            NSArray *events = embedded[@"events"];
            
            [self.mapAnnotations removeAllObjects];
            
            if (events) {
                for(int i = 0; i < [events count] ;++i){
                    NSString* eventName = events[i][@"name"];
                    NSString* eventLocation = events[i][@"_embedded"][@"venues"][0][@"name"];
                    
                    NSString* eventAddress = events[i][@"_embedded"][@"venues"][0][@"address"][@"line1"];
                    NSString* eventCity =  events[i][@"_embedded"][@"venues"][0][@"city"][@"name"];
                    NSString* eventState = events[i][@"_embedded"][@"venues"][0][@"state"][@"name"];
                    NSString* eventCountryCode = events[i][@"_embedded"][@"venues"][0][@"country"][@"countryCode"];;
                    eventAddress = [eventAddress stringByAppendingString:
                                    [NSString stringWithFormat:@" %@, %@, %@", eventCity, eventState, eventCountryCode]];
                    
                    NSString* dateTime = events[i][@"dates"][@"start"][@"dateTime"];
                    NSString* eventDate = [dateTime componentsSeparatedByString:@"T"][0];
                    NSString* eventTime = [dateTime componentsSeparatedByString:@"T"][1];
                    
                    NSString* lat = events[i][@"_embedded"][@"venues"][0][@"location"][@"latitude"];
                    NSString* lon = events[i][@"_embedded"][@"venues"][0][@"location"][@"longitude"];
                    
                    EventAnnotation* ann = [[EventAnnotation alloc] initWithLat:[lat doubleValue] lon:[lon doubleValue] eventName:eventName eventLocationName:eventLocation eventAddress:eventAddress eventDate:eventDate eventTime:eventTime];
                    [self.mapAnnotations addObject:ann];
                    
                }
            }
        }
        [self.mapViewController updateAnnotationsOnMap]; // notify mapController annotations have arrived
        NSLog(@"model told mapVC to update annotations");
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
