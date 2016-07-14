//
//  SettingsViewController.m
//  EventMap
//
//  Created by Emanuel Azage on 5/23/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

#import "SettingsViewController.h"
#import "EventMapModel.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIStepper *numDaysStepper;
@property (weak, nonatomic) IBOutlet UIStepper *maxNumEventsStepper;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *numDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxNumEventsLabel;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (strong, nonatomic) EventMapModel* eventMapModel;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _eventMapModel = [EventMapModel sharedModel];
}

- (IBAction)numDaysChanged:(id)sender {
    NSString* currNumDays = [NSString stringWithFormat:@"%i", (int)[self.numDaysStepper value]];
    [self.numDaysLabel setText:currNumDays];
    [self.eventMapModel setNumDaysForEvents:(int)[self.numDaysStepper value]];
}

- (IBAction)maxNumEventsChanged:(id)sender {
    NSString* currMaxEvents = [NSString stringWithFormat:@"%i", (int)[self.maxNumEventsStepper value]];
    [self.maxNumEventsLabel setText:currMaxEvents];
    [self.eventMapModel setMaxNumForEvents:(int)[self.maxNumEventsStepper value]];
}

- (IBAction)radiusChanged:(id)sender {
    NSString* currRadius = [NSString stringWithFormat:@"%i", (int)[self.radiusSlider value]];
    [self.radiusLabel setText:currRadius];
    [self.eventMapModel setRadiusForEvents:(int)[self.radiusSlider value]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // update the map if we are done setting preferences
    [[self eventMapModel] updateMap];
//    NSLog(@"settingVC told model to update since it is done");
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
