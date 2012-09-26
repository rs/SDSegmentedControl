//
//  ViewController.m
//  Example
//
//  Created by Olivier Poitrey on 26/09/12.
//  Copyright (c) 2012 Hackemist. All rights reserved.
//

#import "ViewController.h"

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
    self.selectedSegmentLabel.text = [NSString stringWithFormat:@"%d", self.segmentedControl.selectedSegmentIndex];
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
@end
