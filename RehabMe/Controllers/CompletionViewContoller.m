//
//  CompletionViewContoller.m
//  RehabMe
//
//  Created by Danny Volz on 3/11/15.
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import "CompletionViewContoller.h"

@interface CompletionViewContoller () {
    int previousStepperValue;
    int totalNumber;
}

@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;


@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *labelValues;
@property (weak, nonatomic) IBOutlet UILabel *labelDates;

@end

@implementation CompletionViewContoller


- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:REHABME_GREEN]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"Lato" size:20.0],
                                               NSFontAttributeName,
                                               nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hydrateDatasets];
    
    [self setupGraph];
}

//- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender {
//    // Dismiss this viewcontroller
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//}





#pragma mark - Graph Stats


- (void) setupGraph {
     self.graphView.delegate = self;
     self.graphView.dataSource = self;
    
    // Customization of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    self.graphView.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    self.graphView.enableTouchReport = YES;
    self.graphView.enablePopUpReport = YES;
    self.graphView.enableYAxisLabel = NO;
    self.graphView.autoScaleYAxis = YES;
    self.graphView.alwaysDisplayDots = NO;
    self.graphView.enableReferenceXAxisLines = YES;
    self.graphView.enableReferenceYAxisLines = NO;
    self.graphView.enableReferenceAxisFrame = YES;
    self.graphView.animationGraphStyle = BEMLineAnimationDraw;
    self.graphView.enableBezierCurve = NO;
  
    // Dash the y reference lines
    self.graphView.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    self.graphView.formatStringForValues = @"%.1f";
    
    // Setup initial curve selection segment
//        self.curveChoice.selectedSegmentIndex = self.graphView.enableBezierCurve;
    
    // The labels to report the values of the graph when the user touches it
    self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.graphView calculatePointValueSum] intValue]];
    self.labelDates.text = @"between 2000 and 2010";
    
}



- (void)updateGraph {
    // Change graph properties
    // Update data source / arrays
    
    // Reload the graph
    [self.graphView reloadGraph];
}


- (void)hydrateDatasets {
    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
//    [query orderByDescending:@"createdAt"];
//    query.limit = 9;
    NSArray* scoreArray = [query findObjects];
    
    totalNumber = 0;
    NSDate *baseDate = [NSDate date];
    BOOL showNullValue = true;
    
    
    if(!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
    if(!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];
    
    for (int i = 0; i < 9; i++) {
        [self.arrayOfValues addObject:@(0)]; // Random values for the graph
        if (i == 0) {
            [self.arrayOfDates addObject:[self dateForGraphBeforeDate:baseDate byTwelveHourIncrements:9-i]]; // Dates for the X-Axis of the graph
        } else if (showNullValue && i == 4) {
            [self.arrayOfDates addObject:[self dateForGraphBeforeDateTwelveHours:self.arrayOfDates[i-1]]]; // Dates for the X-Axis of the graph
            self.arrayOfValues[i] = @(BEMNullGraphValue);
        } else {
            [self.arrayOfDates addObject:[self dateForGraphBeforeDateTwelveHours:self.arrayOfDates[i-1]]]; // Dates for the X-Axis of the graph
        }
    }
    
    
    for (int i = 0; i < [scoreArray count]; i++) {
        PFObject *gameScore = scoreArray[i];
        
        totalNumber = totalNumber + [gameScore[@"score"] intValue]; // All of the values added together

        
        NSTimeInterval timeInterval = [gameScore.createdAt timeIntervalSinceDate:baseDate];

        
        if (fabs(timeInterval) < (SECONDS_IN_A_DAY * 4)) {
            for (int index = 0; index < [self.arrayOfDates count]; index++) {
                NSTimeInterval withinLastTwelveHours = [gameScore.createdAt timeIntervalSinceDate:self.arrayOfDates[index]];
                if (fabs(withinLastTwelveHours) < SECONDS_IN_A_DAY/2) {
                    [self.arrayOfValues replaceObjectAtIndex:index withObject:gameScore[@"score"]];
                }
            }
        }
    }
    


}

- (NSDate *)dateForGraphBeforeDateTwelveHours:(NSDate *)date {
    NSDate *newDate = [date dateByAddingTimeInterval:SECONDS_IN_A_DAY/2];
    return newDate;
}

- (NSDate *)dateForGraphBeforeDate:(NSDate *)date byTwelveHourIncrements:(int)increments {
    NSDate *newDate = [date dateByAddingTimeInterval:-SECONDS_IN_A_DAY/2 * increments];
    return newDate;
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    NSDate *date = self.arrayOfDates[index];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd";
    NSString *label = [df stringFromDate:date];
    return label;
}



#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] doubleValue];
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 1;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self labelForDateAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    self.labelValues.text = [NSString stringWithFormat:@"%@ XP", [self.arrayOfValues objectAtIndex:index]];
    self.labelDates.text = [NSString stringWithFormat:@"on %@", [self labelForDateAtIndex:index]];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelValues.alpha = 0.0;
        self.labelDates.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.labelValues.text = [NSString stringWithFormat:@"%i XP", totalNumber];
        self.labelDates.text = [NSString stringWithFormat:@"%@ to %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.labelValues.alpha = 1.0;
            self.labelDates.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    self.labelValues.text = [NSString stringWithFormat:@"%i XP", totalNumber];
    self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
}



/* - (void)lineGraphDidFinishDrawing:(BEMSimpleLineGraphView *)graph {
 // Use this method for tasks after the graph has finished drawing
 } */

- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @" XP";
}



@end
