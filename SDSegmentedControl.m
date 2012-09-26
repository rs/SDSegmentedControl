//
//  SDSegmentedControl.m
//  Created by Olivier Poitrey on 22/09/12.
//

#import "SDSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

@interface StainView : UIView
@end

@interface SDSegmentedControl ()

@property (strong, nonatomic) NSMutableArray *_items;
@property (strong, nonatomic) UIView *_selectedStainView;

@end

@implementation SDSegmentedControl
{
    NSInteger _selectedSegmentIndex;
}

+ (Class)layerClass
{
    return CAShapeLayer.class;
}

- (id)init
{
    if ((self = [super init]))
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    if ((self = [self init]))
    {
        [items enumerateObjectsUsingBlock:^(id title, NSUInteger idx, BOOL *stop)
        {
            [self insertSegmentWithTitle:title atIndex:idx animated:NO];
        }];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
    _selectedSegmentIndex = super.selectedSegmentIndex;
    for (NSInteger i = 0; i < super.numberOfSegments; i++)
    {
        [self insertSegmentWithTitle:[super titleForSegmentAtIndex:i] atIndex:i animated:NO];
    }
    [super removeAllSegments];
}

- (void)commonInit
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _selectedSegmentIndex = -1;
    self._items = NSMutableArray.array;
    _arrowSize = 8;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    ((CAShapeLayer *)self.layer).fillColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1].CGColor;
    self.layer.backgroundColor = UIColor.clearColor.CGColor;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    [self addSubview:self._selectedStainView = StainView.new];
    self._selectedStainView.backgroundColor = [UIColor colorWithRed:0.816 green:0.816 blue:0.816 alpha:1];
}

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    NSAssert(NO, @"insertSegmentWithImage:atIndex:animated: is not supported on SDSegmentedControl");
}

- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment
{
    NSAssert(NO, @"imageForSegmentAtIndex: is not supported on SDSegmentedControl");
    return nil;
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
    NSAssert(NO, @"setImage:forSegmentAtIndex: is not supported on SDSegmentedControl");
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    NSUInteger index = MAX(MIN(segment, self.numberOfSegments - 1), 0);
    UILabel *segmentView = self._items[index];
    segmentView.text = title;
    [segmentView sizeToFit];
    [self setNeedsLayout];
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
    NSUInteger index = MAX(MIN(segment, self.numberOfSegments - 1), 0);
    UILabel *segmentView = self._items[index];
    return segmentView.text;
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    UILabel *segmentView = UILabel.new;
    segmentView.alpha = 0;
    segmentView.text = title;
    segmentView.textColor = [UIColor colorWithRed:0.451 green:0.451 blue:0.451 alpha:1];
    segmentView.font = [UIFont boldSystemFontOfSize:15];
    segmentView.backgroundColor = UIColor.clearColor;
    segmentView.userInteractionEnabled = YES;
    [segmentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelect:)]];
    [segmentView sizeToFit];

    NSUInteger index = MAX(MIN(segment, self.numberOfSegments), 0);
    if (index < self._items.count)
    {
        segmentView.center = ((UIView *)self._items[index]).center;
        [self insertSubview:segmentView belowSubview:self._items[index]];
        [self._items insertObject:segmentView atIndex:index];
    }
    else
    {
        segmentView.center = self.center;
        [self addSubview:segmentView];
        [self._items addObject:segmentView];
    }

    if (self.selectedSegmentIndex >= index)
    {
        self.selectedSegmentIndex++;
    }

    if (animated)
    {
        [UIView animateWithDuration:.4 animations:^
        {
            [self layoutSegments];
        }];
    }
    else
    {
        [self setNeedsLayout];
    }
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
    if (self._items.count == 0) return;
    NSUInteger index = MAX(MIN(segment, self.numberOfSegments - 1), 0);
    UIView *segmentView = self._items[index];

    if (self.selectedSegmentIndex >= index)
    {
        self.selectedSegmentIndex--;
    }

    if (animated)
    {
        [self._items removeObject:segmentView];
        [UIView animateWithDuration:.4 animations:^
        {
            segmentView.alpha = 0;
            [self layoutSegments];
        }
        completion:^(BOOL finished)
        {
            [segmentView removeFromSuperview];
        }];
    }
    else
    {
        [segmentView removeFromSuperview];
        [self._items removeObject:segmentView];
        [self setNeedsLayout];
    }
}

- (void)removeAllSegments
{
    [self._items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self._items removeAllObjects];
    [self setNeedsLayout];
}

- (NSUInteger)numberOfSegments
{
    return self._items.count;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    CGRect frame = self.frame;
    if (frame.size.height == 0)
    {
        frame.size.height = 45;
    }
    if (frame.size.width == 0)
    {
        frame.size.width = CGRectGetWidth(newSuperview.bounds);
    }
}

- (void)setArrowSize:(CGFloat)arrowSize
{
    _arrowSize = arrowSize;
    [self setNeedsLayout];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    if (_selectedSegmentIndex != selectedSegmentIndex)
    {
        NSParameterAssert(selectedSegmentIndex < self._items.count);
        _selectedSegmentIndex = selectedSegmentIndex;
        [self setNeedsLayout];
    }
}

- (NSInteger)selectedSegmentIndex
{
    return _selectedSegmentIndex;
}

- (void)layoutSubviews
{
    [self layoutSegments];
}

- (void)layoutSegments
{
    CGFloat totalItemWidth = 0;
    for (UIView *item in self._items)
    {
        totalItemWidth += CGRectGetWidth(item.bounds);
    }

    CGFloat spaceLeft = CGRectGetWidth(self.bounds) - totalItemWidth;
    CGFloat interItemSpace = spaceLeft / (CGFloat)(self._items.count + 1);
    CGFloat itemsVAlignCenter = (CGRectGetHeight(self.bounds) - self.arrowSize / 2) / 2;

    __block CGFloat pos = interItemSpace;
    [self._items enumerateObjectsUsingBlock:^(UIView *item, NSUInteger idx, BOOL *stop)
    {
        item.alpha = 1;
        if (self.selectedSegmentIndex == idx)
        {
            [item sizeToFit];
            item.center = CGPointMake(pos + CGRectGetWidth(item.bounds) / 2, itemsVAlignCenter);
        }
        else
        {
            item.frame = CGRectMake(pos, 0, CGRectGetWidth(item.bounds), itemsVAlignCenter * 2);
        }
        pos += CGRectGetWidth(item.bounds) + interItemSpace;
    }];
    for (UIView *item in self._items)
    {
    }

    if (self.selectedSegmentIndex == -1)
    {
        self._selectedStainView.hidden = 0;
        [self drawSelectedMaskAtPosition:-1];
    }
    else
    {
        UIView *selectedItem = self._items[self.selectedSegmentIndex];
        CGRect stainFrame = CGRectInset(selectedItem.frame, -15, -3);
        self._selectedStainView.layer.cornerRadius = stainFrame.size.height / 2;
        BOOL animated = !self._selectedStainView.hidden && !CGRectEqualToRect(self._selectedStainView.frame, CGRectZero);
        UIView.animationsEnabled = animated;
        [UIView animateWithDuration:animated ? 0.2 : 0 animations:^
        {
            self._selectedStainView.frame = stainFrame;
        }
        completion:^(BOOL finished)
        {
            for (UILabel *item in self._items)
            {
                if (item == selectedItem)
                {
                    item.textColor = [UIColor colorWithRed:0.169 green:0.169 blue:0.169 alpha:1];
                    item.shadowColor = UIColor.whiteColor;
                    item.shadowOffset = CGSizeMake(0, 1);
                }
                else
                {
                    item.textColor = [UIColor colorWithRed:0.451 green:0.451 blue:0.451 alpha:1];
                }
            }

            [self drawSelectedMaskAtPosition:selectedItem.center.x];
        }];
        UIView.animationsEnabled = YES;
    }
}

- (void)drawSelectedMaskAtPosition:(CGFloat)position
{
    // TODO: make this animatable
    UIBezierPath *path = UIBezierPath.new;
    CGRect bounds = self.bounds;
    [path moveToPoint:bounds.origin];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))];
    if (position >= 0)
    {
        [path addLineToPoint:CGPointMake(position + self.arrowSize, CGRectGetMaxY(bounds))];
        [path addLineToPoint:CGPointMake(position, CGRectGetMaxY(bounds) - self.arrowSize)];
        [path addLineToPoint:CGPointMake(position - self.arrowSize, CGRectGetMaxY(bounds))];
    }
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds))];
    [path addLineToPoint:bounds.origin];
    ((CAShapeLayer *)self.layer).path = path.CGPath;
}

- (void)handleSelect:(UIGestureRecognizer *)gestureRecognizer
{
    NSUInteger index = [self._items indexOfObject:gestureRecognizer.view];
    if (index != NSNotFound)
    {
        self.selectedSegmentIndex = index;
        [self setNeedsLayout];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end

@implementation StainView

- (id)init
{
    if ((self = [super init]))
    {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, -1, -1) cornerRadius:self.layer.cornerRadius].CGPath;
    CGContextAddPath(context, roundedRect);
    CGContextClip(context);

    CGContextAddPath(context, roundedRect);
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 1), 3, UIColor.blackColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.backgroundColor.CGColor);
    CGContextStrokePath(context);
}

@end
