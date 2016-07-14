//
//  AddEventViewController.m
//  EventMap
//
//  Created by Emanuel Azage on 4/27/16.
//  Email: eazage@usc.edu
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

#import "AddEventViewController.h"
#import "EventMapModel.h"

@interface AddEventViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addEventButton;

@property (strong, nonatomic) EventAnnotation *annotation;
@property (strong, nonatomic) EventMapModel* eventMapModel;
@end

@implementation AddEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _eventMapModel = [EventMapModel sharedModel];
    self.annotation = _eventMapModel.getSelectedAnnotation;
    
    if(_annotation != nil){
        self.eventNameLabel.text = self.annotation.eventName;
        self.eventLocationNameLabel.text = self.annotation.eventLocationName;
        self.eventAddressLabel.text = self.annotation.eventAddress;
        self.eventDateLabel.text = self.annotation.eventDate;
        self.eventTimeLabel.text = self.annotation.eventTime;
        
        if([self.eventMapModel isInUsersList:self.annotation]){ //already in the user's list of events
            [self.addEventButton setEnabled:NO]; // cant add an event thats already been added
            [self.addEventButton setHidden:YES];
        }
    }
}


- (IBAction)addEventButtonClicked:(id)sender {
    [self.eventMapModel addEventToUsersList:self.annotation];
    [self.addEventButton setEnabled:NO];
    [self.addEventButton setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
