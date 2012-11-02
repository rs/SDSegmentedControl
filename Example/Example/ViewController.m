//
//  ViewController.m
//  Example
//
//  Created by Olivier Poitrey on 26/09/12.
//  Copyright (c) 2012 Hackemist. All rights reserved.
//

#import "ViewController.h"
#import "SDSegmentedControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateSelectedSegmentLabel];
}

- (void)updateSelectedSegmentLabel
{
    self.selectedSegmentLabel.font = [UIFont boldSystemFontOfSize:self.selectedSegmentLabel.font.pointSize];
    self.selectedSegmentLabel.text = [NSString stringWithFormat:@"%d", self.segmentedControl.selectedSegmentIndex];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
    {
        self.selectedSegmentLabel.font = [UIFont systemFontOfSize:self.selectedSegmentLabel.font.pointSize];
    });
}

- (IBAction)segmentDidChange:(id)sender
{
    [self updateSelectedSegmentLabel];
}

- (IBAction)removeSegment:(id)sender
{
    [self.segmentedControl removeSegmentAtIndex:0 animated:YES];
    [self updateSelectedSegmentLabel];
}

- (IBAction)addSegment:(id)sender
{
    [self.segmentedControl insertSegmentWithTitle:@"New" atIndex:0 animated:YES];
    [self updateSelectedSegmentLabel];
}

- (IBAction)disableSegment:(id)sender
{
    [self.segmentedControl setEnabled:NO forSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
}

- (IBAction)addImage:(id)sender
{
    [self.segmentedControl setImage:[UIImage imageNamed:@"clock.png"] forSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
}

- (IBAction)customizeTheme:(id)sender
{
    SDSegmentedControl *segmentedControlAppearance = SDSegmentedControl.appearance;
    segmentedControlAppearance.backgroundColor = UIColor.redColor;
    segmentedControlAppearance.arrowSize = 10;

    SDSegmentView *segmenteViewAppearance = SDSegmentView.appearance;
    [segmenteViewAppearance setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
    [segmenteViewAppearance setTitleColor:UIColor.blueColor forState:UIControlStateSelected];
    [segmenteViewAppearance setTitleColor:UIColor.yellowColor forState:UIControlStateDisabled];

    SDStainView *stainViewAppearance = SDStainView.appearance;
    stainViewAppearance.backgroundColor = UIColor.orangeColor;
    stainViewAppearance.shadowColor = UIColor.greenColor;
    stainViewAppearance.shadowBlur = 5;

    [self presentViewController:ViewController.new animated:NO completion:nil];
}

@end
