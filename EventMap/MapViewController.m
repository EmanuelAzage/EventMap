//
//  MapViewController.m
//  EventMap
//
//  Created by Emanuel Azage on 4/26/16.
//  Email: eazage@usc.edu
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

#import "MapViewController.h"
#import "AddEventViewController.h"
#import "EventAnnotation.h"
#import "EventMapModel.h"

static const double kUpdateEverySoMeters = 100.0; // in meters, the distance a user need to move for new
                                                // annotations to be loaded

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) NSMutableArray *mapAnnotations;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) EventMapModel* eventMapModel;
@end

@implementation MapViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // restore the nav bar to translucent
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    
    [self.locationManager setDistanceFilter:1000.0f];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _eventMapModel = [EventMapModel sharedModel];
    [self.eventMapModel setMapViewController:self];
    
    // get annotations from model once model works
    self.mapAnnotations = [[NSMutableArray alloc] init];
    
    _locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager setDesiredAccuracy: kCLLocationAccuracyHundredMeters];
    [self.locationManager setDistanceFilter:1000.0f];
    [self.locationManager startUpdatingLocation];
    
    self.locationManager.delegate = self;
    
    [self.mapView setDelegate:self];
    [self.mapView setShowsUserLocation:YES];
    
}

-(void)updateAnnotationsOnMap{
    _mapAnnotations = [self.eventMapModel getAnnotations];
    
    // remove any annotations that exist
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // add all the custom annotations
    [self.mapView addAnnotations:self.mapAnnotations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

// open up the add event view
-(void)buttonAction:(id)sender{
    
    AddEventViewController *aevc = [[self storyboard] instantiateViewControllerWithIdentifier:@"AddEventViewController"];
    
//    aevc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    aevc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    aevc.edgesForExtendedLayout = UIRectEdgeNone;
    aevc.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *presentationController = aevc.popoverPresentationController;
    
    // display popover from the UIButton (sender) as the anchor
    presentationController.sourceRect = [sender frame];
    UIButton *button = (UIButton *)sender;
    presentationController.sourceView = button.superview;
    
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    // not required, but useful for presenting "contentVC" in a compact screen so that it
    // can be dismissed as a full screen view controller)
    //
    presentationController.delegate = self;
//
    [self presentViewController:aevc animated:YES completion:^{}];
}

- (void)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma Map Delegates


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *newLocation = [locations lastObject];
    
    //     set the span size
    [self.mapView setRegion: MKCoordinateRegionMake(newLocation.coordinate, MKCoordinateSpanMake(0.5f, 0.5f)) animated:YES];

    if([self.eventMapModel lastUserLoc]){
        
        if([self locationChangedSignificantly:newLocation]){// if the user has changed locations
            // ask the model to get new annotations for the updated location
            // uses TM api to get events and then the model will notify this controller when events arrive
            [self.eventMapModel getEventsForLat:newLocation.coordinate.latitude Long:newLocation.coordinate.longitude];
            [self.eventMapModel setLastUserLoc: newLocation]; // update lastLoc if the user changed locations significantly
        }
    } else{
        
        // ask the model to get new annotations for the updated location
        // uses TM api to get events and then the model will notify this controller when events arrive
        [self.eventMapModel getEventsForLat:newLocation.coordinate.latitude Long:newLocation.coordinate.longitude];
        [self.eventMapModel setLastUserLoc: newLocation]; // update lastLoc if the user changed locations significantly
    }
}

-(Boolean) locationChangedSignificantly: (CLLocation*) newLoc{
    // distance between two points formula to determine how much a user has moved
    double degDistance = sqrt(  pow(newLoc.coordinate.latitude - [self.eventMapModel lastUserLoc].coordinate.latitude, 2) + pow(newLoc.coordinate.longitude - [self.eventMapModel lastUserLoc].coordinate.longitude, 2)  );
    
    double meterDistance = degDistance*1000/.00861701; // convertion factor from deg to meters
    if(meterDistance <= kUpdateEverySoMeters){ // change of x meters required to update map annotations
        return NO;
    } else {
        return YES;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self.eventMapModel setSelectedAnnotation: (EventAnnotation*)view.annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *returnedAnnotationView = nil;
    
    // in case it's the user location, we already have an annotation, so just return nil
    if (![annotation isKindOfClass:[MKUserLocation class]])
    {
        // handle our custom annotations
        //
        if ([annotation isKindOfClass:[EventAnnotation class]]) // for Golden Gate Bridge
        {
            returnedAnnotationView = [EventAnnotation createViewAnnotationForMapView:self.mapView annotation:annotation];
        
            // add a detail disclosure button to the callout which will open a new view controller page or a popover
            //
            // note: when the detail disclosure button is tapped, we respond to it via:
            //       calloutAccessoryControlTapped delegate method
            //
            // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
            //
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            returnedAnnotationView.rightCalloutAccessoryView = rightButton;
        }
    }

    return returnedAnnotationView;
    
}

#pragma popover presentation delegate
- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    
    // for the detail view controller we want a black style nav bar
    navController.navigationBar.barStyle = UIBarStyleDefault;
    
    UIViewController *presentedViewController = controller.presentedViewController;
    if (presentedViewController != nil)
    {
        presentedViewController.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(doneAction:)];
    }
    
    return navController;
}

@end
