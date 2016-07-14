//
//  EventAnnotation.m
//  EventMap
//
//  Created by Emanuel Azage on 4/27/16.
//  Email: eazage@usc.edu
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

#import "EventAnnotation.h"

@interface EventAnnotation()

@end

@implementation EventAnnotation

-(instancetype) initWithLat:(double) inLat lon:(double) inLon eventName:(NSString*) eventName eventLocationName:(NSString*) eventLocationName eventAddress:(NSString*) eventAddress eventDate:(NSString*) eventDate eventTime:(NSString*) eventTime{
    
    self = [super init];
    if (self) {
        _lat = inLat;
        _lon = inLon;
        self.eventName = eventName;
        self.eventLocationName = eventLocationName;
        self.eventAddress = eventAddress;
        self.eventDate = eventDate;
        self.eventTime = eventTime;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.lat, self.lon);
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return [self eventName];
}

// optional
- (NSString *)subtitle
{
    return [self eventDate];
}

+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation
{
    // try to dequeue an existing pin view first
    MKAnnotationView *returnedAnnotationView =
    [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([EventAnnotation class])];
    if (returnedAnnotationView == nil)
    {
        returnedAnnotationView =
        [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                        reuseIdentifier:NSStringFromClass([EventAnnotation class])];
        
        ((MKPinAnnotationView *)returnedAnnotationView).pinTintColor = [MKPinAnnotationView redPinColor];
        ((MKPinAnnotationView *)returnedAnnotationView).animatesDrop = YES;
        ((MKPinAnnotationView *)returnedAnnotationView).canShowCallout = YES;
    }
    
    return returnedAnnotationView;
}



@end
