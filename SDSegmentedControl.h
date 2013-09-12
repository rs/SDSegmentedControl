//
//  SDSegmentedControl.h
//  Created by Olivier Poitrey on 22/09/12.
//  Contributed by Marius Rackwitz on 19/10/12
//

// #define SDSegmentedControlDebug 1

#import <UIKit/UIKit.h>

// Most inherited UI_APPERANCE_SELECTORs are ignored. You can use the following selectors
// to customize appearance:
//  +[SDSegmentedControl appearance]
//  +[SDSegmentView appearance]
//  +[SDStainView appearance]

@interface SDSegmentedControl : UISegmentedControl <UIScrollViewDelegate>

@property (retain, nonatomic) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property (retain, nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat arrowSize UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat arrowHeightFactor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CFTimeInterval animationDuration UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat interItemSpace UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) UIEdgeInsets stainEdgeInsets UI_APPEARANCE_SELECTOR;
@property (retain, nonatomic) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat shadowRadius UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat shadowOpacity UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGSize shadowOffset UI_APPEARANCE_SELECTOR;

@property UIScrollView *scrollView;

@end

@interface SDSegmentView : UIButton

@property (assign, nonatomic) CGSize imageSize UI_APPEARANCE_SELECTOR;
@property (retain, nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (retain, nonatomic) UIFont *selectedTitleFont UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGSize titleShadowOffset UI_APPEARANCE_SELECTOR;

@end

@interface SDStainView : UIView <UIAppearance>

@property (retain, nonatomic) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) UIEdgeInsets edgeInsets UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGSize shadowOffset UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat shadowBlur UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat innerStrokeLineWidth UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) UIColor *innerStrokeColor UI_APPEARANCE_SELECTOR;

@end
