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
{
    NSUInteger addCount;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    addCount = 0;
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
    switch (addCount++ % 4)
    {
        case 0:
            [self.segmentedControl insertSegmentWithTitle:@"Title Only" atIndex:0 animated:YES];
            break;

        case 1:
            [self.segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"clock"] atIndex:0 animated:YES];
            break;

        case 2:
            [self.segmentedControl insertSegmentWithTitle:@"Title with Image" atIndex:0 animated:YES];
            [self.segmentedControl setImage:[UIImage imageNamed:@"clock"] forSegmentAtIndex:0];
            break;

        case 3:
            [self.segmentedControl insertSegmentWithTitle:@"Custom Width" atIndex:0 animated:YES];
            [self.segmentedControl setWidth:200.0 forSegmentAtIndex:0];
            break;
    }

    [self updateSelectedSegmentLabel];
}

- (IBAction)disableSegment:(id)sender
{
    [self.segmentedControl setEnabled:NO forSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
}

- (IBAction)addImage:(id)sender
{
    [self.segmentedControl setImage:[UIImage imageNamed:@"clock"] forSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
}

- (IBAction)customizeTheme:(id)sender
{
    SDSegmentedControl *segmentedControlAppearance = SDSegmentedControl.appearance;
    segmentedControlAppearance.backgroundColor = UIColor.redColor;
    segmentedControlAppearance.borderColor = UIColor.greenColor;
    segmentedControlAppearance.arrowSize = 20;
    segmentedControlAppearance.arrowHeightFactor = 0.50;
    segmentedControlAppearance.titleFont = [UIFont fontWithName:@"Copperplate" size:15.0];
    segmentedControlAppearance.selectedTitleFont = [UIFont fontWithName:@"BradleyHandITCTT-Bold" size:15.0];

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

- (IBAction)toggleArrow:(id)sender
{
    SDSegmentedControl* sdSegmentedControl = (SDSegmentedControl *)_segmentedControl;
    sdSegmentedControl.arrowSize = sdSegmentedControl.arrowSize > 0 ? 0 : 6.5;
}

- (IBAction)invertArrowDirection:(id)sender {
    ((SDSegmentedControl *)_segmentedControl).arrowHeightFactor *= -1.0;
}

- (IBAction)changeArrowPosition:(id)sender;
{
    SDSegmentedControl* sdSegmentedControl = (SDSegmentedControl *)_segmentedControl;
    sdSegmentedControl.arrowPosition = sdSegmentedControl.arrowPosition == SDSegmentedArrowPositionBottom ? SDSegmentedArrowPositionTop : SDSegmentedArrowPositionBottom;
}

@end
