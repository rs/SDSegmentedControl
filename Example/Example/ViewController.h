//
//  ViewController.h
//  Example
//
//  Created by Olivier Poitrey on 26/09/12.
//  Copyright (c) 2012 Hackemist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentDidChange:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *selectedSegmentLabel;
- (IBAction)removeSegment:(id)sender;
- (IBAction)addSegment:(id)sender;
- (IBAction)disableSegment:(id)sender;
- (IBAction)addImage:(id)sender;
- (IBAction)customizeTheme:(id)sender;
- (IBAction)toggleArrow:(id)sender;
- (IBAction)invertArrowDirection:(id)sender;
- (IBAction)changeArrowPosition:(id)sender;

@end
