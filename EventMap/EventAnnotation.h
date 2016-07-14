//
//  EventAnnotation.h
//  EventMap
//
//  Created by Emanuel Azage on 4/27/16.
//  Email: eazage@usc.edu
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface EventAnnotation : NSObject <MKAnnotation>


@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *eventLocationName;
@property (nonatomic, strong) NSString *eventAddress;
@property (nonatomic, strong) NSString *eventDate;
@property (nonatomic, strong) NSString *eventTime;
@property (nonatomic) double lat, lon;

-(instancetype) initWithLat:(double) inLat lon: (double) inLon eventName:(NSString*) eventName eventLocationName:(NSString*) eventLocationName eventAddress:(NSString*) eventAddress eventDate:(NSString*) eventDate eventTime:(NSString*) eventTime;

+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation;

@end
