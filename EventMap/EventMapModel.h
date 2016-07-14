//
//  EventMapModel.h
//  EventMap
//
//  Created by Emanuel Azage on 4/30/16.
//  Email: eazage@usc.edu
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventAnnotation.h"
#import "MapViewController.h"

static NSString* const kEventsPList = @"usersEvents.plist";
static NSString* const kEventsArrayKey = @"EventsArrayKey";

static NSString* const kEventName = @"EventName";
static NSString* const kEventLocationName = @"EventLocationName";
static NSString* const kEventAddress = @"EventAddress";
static NSString* const kEventDate = @"EventDate";
static NSString* const kEventTime = @"EventTime";
static NSString* const kLatitude = @"Latitude";
static NSString* const kLongitude = @"Longitude";

@interface EventMapModel : NSObject

+(instancetype)sharedModel;

@property (nonatomic, strong) CLLocation* lastUserLoc;

@property (nonatomic) int numDaysForEvents;
@property (nonatomic) int maxNumForEvents;
@property (nonatomic) int radiusForEvents;

-(NSMutableArray*)getAnnotations;
-(void) getEventsForLat: (double)lat Long: (double) lon;
-(EventAnnotation*) getSelectedAnnotation;
-(void) setSelectedAnnotation:(EventAnnotation*)annotation;
-(Boolean) isInUsersList: (EventAnnotation*) annotation;
-(void) addEventToUsersList: (EventAnnotation*) eventAnn;
-(void) saveUsersEvents;
-(void) setMapViewController:(MapViewController *)mapViewController;
-(NSMutableArray*) getUserEvents;
-(NSUInteger) getNumberOfUserEvents;
-(NSString*) getUserEventNameAtIndex: (NSUInteger) index;
-(void) removeUserEventAtIndex:(NSUInteger)index;
-(void) updateMap;
@end
