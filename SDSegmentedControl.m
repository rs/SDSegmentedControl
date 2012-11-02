//
//  SDSegmentedControl.m
//  Created by Olivier Poitrey on 22/09/12.
//  Contributed by Marius Rackwitz on 19/10/12
//

#import "SDSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Constants

const NSTimeInterval kSDSegmentedControlDefaultDuration = 0.2;
const CGFloat kSDSegmentedControlArrowSize = 6.5;


@interface StainView : UIView
@end

@interface SDSegmentedControl ()

@property (strong, nonatomic) NSMutableArray *_items;
@property (strong, nonatomic) UIView *_selectedStainView;

@end

@implementation SDSegmentedControl
{
    NSInteger _selectedSegmentIndex;
    NSInteger _lastSelectedSegmentIndex;
    CAShapeLayer *_borderBottomLayer;
    void (^lastCompletionBlock)();
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
    // Init properties
    _lastSelectedSegmentIndex = -1;
    _selectedSegmentIndex = -1;
    __items = NSMutableArray.array;

    // Appearance properties
    _animationDuration = kSDSegmentedControlDefaultDuration;
    _arrowSize = kSDSegmentedControlArrowSize;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    // Reset UIKit original widget
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // Init layer
    ((CAShapeLayer *)self.layer).fillColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1].CGColor;
    self.layer.backgroundColor = UIColor.clearColor.CGColor;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowRadius = .8;
    self.layer.shadowOpacity = .6;
    self.layer.shadowOffset = CGSizeMake(0, 1);

    // Init border bottom layer
    _borderBottomLayer = [CAShapeLayer layer];
    _borderBottomLayer.strokeColor = UIColor.whiteColor.CGColor;
    _borderBottomLayer.lineWidth = .5;
    _borderBottomLayer.fillColor = nil;
    [self.layer addSublayer:_borderBottomLayer];


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
    segmentView.textColor = [UIColor colorWithRed:0.235 green:0.235 blue:0.235 alpha:1];
    segmentView.font = [UIFont boldSystemFontOfSize:14];
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
    _lastSelectedSegmentIndex = self.selectedSegmentIndex;

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

    if (self.selectedSegmentIndex >= 0)
    {
        BOOL changed = NO;

        if (self._items.count == 1)
        {
            // Deselect if there is no item
            self.selectedSegmentIndex = -1;
            changed = YES;
        }
        else if (self.selectedSegmentIndex == index)
        {
            // Inform that the old value doesn't exist anymore
            changed = YES;
        }
        else if (self.selectedSegmentIndex > index)
        {
            self.selectedSegmentIndex--;
        }

        // It is important to set both, this will fix the animation.
        _lastSelectedSegmentIndex = self.selectedSegmentIndex;

        if (changed)
        {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
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
    self.selectedSegmentIndex = -1;
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
        frame.size.height = 43;
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
        NSParameterAssert(selectedSegmentIndex < (NSInteger)self._items.count);
        _lastSelectedSegmentIndex = _selectedSegmentIndex;
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

    CGFloat interItemSpace = 30;
    CGFloat spaceLeft = CGRectGetWidth(self.bounds) - (totalItemWidth + (interItemSpace * (self.numberOfSegments - 1)));
    CGFloat itemsVAlignCenter = ((CGRectGetHeight(self.bounds) - self.arrowSize / 2) / 2) + 1;

    __block CGFloat pos = spaceLeft / 2;
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

    BOOL animated = self.animationDuration && !CGRectEqualToRect(self._selectedStainView.frame, CGRectZero);
    CGFloat position;

    if (self.selectedSegmentIndex == -1)
    {
        self._selectedStainView.hidden = YES;
        position = CGFLOAT_MAX;
    }
    else
    {
        UIView *selectedItem = self._items[self.selectedSegmentIndex];
        position = selectedItem.center.x;
        CGRect stainFrame = CGRectInset(selectedItem.frame, -8, -2.5);
        self._selectedStainView.layer.cornerRadius = stainFrame.size.height / 2;
        UIView.animationsEnabled = animated;
        [UIView animateWithDuration:animated ? self.animationDuration : 0 animations:^
        {
            self._selectedStainView.frame = stainFrame;
        }
        completion:^(BOOL finished)
        {
            for (UILabel *item in self._items)
            {
                if (item == selectedItem)
                {
                    item.textColor = [UIColor colorWithRed:0.235 green:0.235 blue:0.235 alpha:1];
                    item.shadowColor = UIColor.whiteColor;
                    item.shadowOffset = CGSizeMake(0, .5);
                }
                else
                {
                    item.textColor = [UIColor colorWithRed:0.392 green:0.392 blue:0.392 alpha:1];
                }
            }
        }];
        UIView.animationsEnabled = YES;
    }

    // Animate from a custom oldPosition if needed
    CGFloat oldPosition = CGFLOAT_MAX;
    if (animated && _lastSelectedSegmentIndex != self.selectedSegmentIndex && _lastSelectedSegmentIndex >= 0 && _lastSelectedSegmentIndex < self._items.count)
    {
        UIView *lastSegmentView = [self._items objectAtIndex:_lastSelectedSegmentIndex];
        oldPosition = lastSegmentView.center.x;
    }

    [self drawPathsFromPosition:oldPosition toPosition:position animationDuration:animated ? self.animationDuration : 0];

}

#pragma mark - Draw paths
// Actually paths are not drawn here, instead they are relayouted

- (void)drawPathsToPosition:(CGFloat)position animated:(BOOL)animated
{
    [self drawPathsToPosition:position animationDuration:animated ? self.animationDuration : 0 completion:nil];
}

- (void)drawPathsToPosition:(CGFloat)position animationDuration:(CFTimeInterval)duration completion:(void (^)(void))completion
{
    [self drawPathsFromPosition:CGFLOAT_MAX toPosition:position animationDuration:duration completion:completion];
}

- (void)drawPathsFromPosition:(CGFloat)oldPosition toPosition:(CGFloat)position animationDuration:(CFTimeInterval)duration
{
    [self drawPathsFromPosition:oldPosition toPosition:position animationDuration:duration completion:nil];
}

- (void)drawPathsFromPosition:(CGFloat)oldPosition toPosition:(CGFloat)position animationDuration:(CFTimeInterval)duration completion:(void (^)(void))completion
{
    CGRect bounds = self.bounds;
    CGFloat left = CGRectGetMinX(bounds);
    CGFloat right = CGRectGetMaxX(bounds);
    CGFloat top = CGRectGetMinY(bounds);
    CGFloat bottom = CGRectGetMaxY(bounds);

    //
    // Mask
    //
    __block UIBezierPath *path = UIBezierPath.new;
    [path moveToPoint:bounds.origin];
    [self addArrowAtPoint:CGPointMake(position, bottom) toPath:path withLineWidth:0.0];
    [path addLineToPoint:CGPointMake(right, top)];
    [path addLineToPoint:CGPointMake(left, top)];

    //
    // Shadow mask
    //
    top += 10;
    __block UIBezierPath *shadowPath = UIBezierPath.new;
    [shadowPath moveToPoint:CGPointMake(left, top)];
    [self addArrowAtPoint:CGPointMake(position, bottom) toPath:shadowPath withLineWidth:0.0];
    [shadowPath addLineToPoint:CGPointMake(right, top)];
    [shadowPath addLineToPoint:CGPointMake(left, top)];

    //
    // Bottom white line
    //
    _borderBottomLayer.frame = self.bounds;
    __block UIBezierPath *borderBottomPath = UIBezierPath.new;
    const CGFloat lineY = bottom - _borderBottomLayer.lineWidth;
    [self addArrowAtPoint:CGPointMake(position, lineY) toPath:borderBottomPath withLineWidth:_borderBottomLayer.lineWidth];


    // Skip current animations and ensure the completion block was applied
    // otherwise this will end up in ugly effects if the selection was changed very fast
    [self.layer removeAllAnimations];
    [_borderBottomLayer removeAllAnimations];
    if (lastCompletionBlock)
    {
        lastCompletionBlock();
    }

    // Build block
    void(^assignLayerPaths)() = ^
    {
        ((CAShapeLayer *)self.layer).path = path.CGPath;
        self.layer.shadowPath = shadowPath.CGPath;
        _borderBottomLayer.path = borderBottomPath.CGPath;

        // Dereference itself to be not executed twice
        lastCompletionBlock = nil;
    };

    __block void(^animationCompletion)();
    if (completion)
    {
        animationCompletion = ^
        {
            assignLayerPaths();
            completion();
        };
    }
    else
    {
        animationCompletion = assignLayerPaths;
    }

    // Apply new paths
    if (duration > 0)
    {
        // That's a bit fragile: we detect stop animation call by duration!
        NSString *timingFuncName = duration < self.animationDuration ? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseInEaseOut;

        // Check if we have to do a stop animation, which means that we first
        // animate to have a fully visible arrow and then move the arrow.
        // Otherwise there will be ugly effects.
        CFTimeInterval stopDuration = -1;
        CGFloat stopPosition = -1;
        if (oldPosition < CGFLOAT_MAX)
        {
            if (oldPosition < left+self.arrowSize)
            {
                stopPosition = left+self.arrowSize;
            }
            else if (oldPosition > right-self.arrowSize)
            {
                stopPosition = right-self.arrowSize;
            }

            if (stopPosition > 0)
            {
                float relStopDuration = ABS((stopPosition - oldPosition) / (position - oldPosition));
                if (relStopDuration > 1)
                {
                    relStopDuration = 1.0 / relStopDuration;
                }
                stopDuration = duration * relStopDuration;
                duration -= stopDuration;
                timingFuncName  = kCAMediaTimingFunctionEaseOut;
            }
        }

        void (^animation)() = ^
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:timingFuncName];
            [CATransaction setAnimationTimingFunction:timing];
            [CATransaction setCompletionBlock:animationCompletion];

            [self addAnimationWithDuration:duration onLayer:self.layer forKey:@"path" toPath:path];
            [self addAnimationWithDuration:duration onLayer:self.layer forKey:@"shadow" toPath:shadowPath];
            [self addAnimationWithDuration:duration onLayer:_borderBottomLayer forKey:@"path" toPath:borderBottomPath];

            [CATransaction commit];
        };

        if (stopPosition > 0)
        {
            [self drawPathsToPosition:stopPosition animationDuration:stopDuration completion:animation];
        }
        else
        {
            animation();
        }

        // Remember completion block
        lastCompletionBlock = assignLayerPaths;
    }
    else
    {
        assignLayerPaths();
    }

}

- (void)addAnimationWithDuration:(CFTimeInterval)duration onLayer:(CALayer *)layer forKey:(NSString *)key toPath:(UIBezierPath *)path
{
    NSString* camelCaseKeyPath;
    NSString* keyPath;

    if (key == @"path")
    {
        camelCaseKeyPath = key;
        keyPath = key;
    }
    else
    {
        camelCaseKeyPath = [NSString stringWithFormat:@"%@Path", key];
        keyPath = [NSString stringWithFormat:@"%@.path", key];
    }

    CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:camelCaseKeyPath];
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.duration = duration;
    pathAnimation.fromValue = [layer valueForKey:keyPath];
    pathAnimation.toValue = (id)path.CGPath;
    [layer addAnimation:pathAnimation forKey:key];
}

- (void)addArrowAtPoint:(CGPoint)point toPath:(UIBezierPath *)path withLineWidth:(CGFloat)lineWidth
{
    // The arrow is added like below, whereas P is the point argument
    // and 1-5 are the points which were added to the path. It must be
    // always five points, otherwise animations will look ugly.
    //
    // P: point.x
    // s: self.arrowSize - line.width
    // w: self.bounds.size.width
    //
    //
    //   s < P < w-s:      P < -s:         P = MAX:       w+s < P:
    //
    //        3
    //       / \
    //      /   \
    //  1--2  P  4--5   1234--------5   1--2--3--4--5   1--------2345
    //
    //
    //    0 < P < s:       -s < P:
    //
    //     3
    //    / \           123
    //  12   \             \
    //     P  4-----5    P  4------5
    //

    const CGFloat left = CGRectGetMinX(self.bounds);
    const CGFloat right = CGRectGetMaxX(self.bounds);
    const CGFloat center = (right-left) / 2;
    const CGFloat width = self.arrowSize - lineWidth;
    const CGFloat height = self.arrowSize + lineWidth/2;

    __block NSMutableArray *points = NSMutableArray.new;
    BOOL hasCustomLastPoint = NO;

    void (^addPoint)(CGFloat x, CGFloat y) = ^(CGFloat x, CGFloat y)
    {
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    };

    // Add first point
    addPoint(left, point.y);

    if (point.x >= left+width && point.x <= right-width)
    {
        // Arrow is completely inside the view
        addPoint(point.x - width, point.y);
        addPoint(point.x,         point.y - height);
        addPoint(point.x + width, point.y);
    }
    else
    {
        // Just some tricks, to allow correctly cutted arrows and
        // to have always a proper animation.
        if (point.x <= left-width)
        {
            // Left aligned points
            addPoint(left + 0.01, point.y);
            addPoint(left + 0.02, point.y);
            addPoint(left + 0.03, point.y);
        }
        else if (point.x < left+width && point.x > left-width)
        {
            // Left cutted arrow
            [points removeAllObjects]; // Custom first point
            if (point.x < left)
            {
                CGFloat x = width + point.x;
                addPoint(left,        point.y - x);
                addPoint(left + 0.01, point.y - x + 0.01);
                addPoint(left + 0.02, point.y - x + 0.02);
                addPoint(left + x,    point.y);
            }
            else
            {
                CGFloat x = width - point.x;
                addPoint(left,            point.y - x);
                addPoint(left + 0.01,     point.y - x + 0.01);
                addPoint(point.x,         point.y - height);
                addPoint(point.x + width, point.y);
            }
        }
        else if (point.x == CGFLOAT_MAX)
        {
            // Centered "arrow", with zero height
            addPoint(center - width, point.y);
            addPoint(center,         point.y);
            addPoint(center + width, point.y);
        }
        else if (point.x < right+width && point.x > right-width)
        {
            // Right cutted arrow, is like left cutted arrow but:
            //  * swapped if/else case
            //  * inverse point order
            //  * other calculation of x
            hasCustomLastPoint = YES; // Custom last point
            if (point.x < right)
            {
                CGFloat x = width - (right - point.x);
                addPoint(point.x - width, point.y);
                addPoint(point.x,         point.y - height);
                addPoint(right - 0.01,    point.y - x + 0.01);
                addPoint(right,           point.y - x);
            }
            else
            {
                CGFloat x = width + (right - point.x);
                addPoint(right - x,    point.y);
                addPoint(right - 0.02, point.y - x + 0.02);
                addPoint(right - 0.01, point.y - x + 0.01);
                addPoint(right,        point.y - x);
            }
        }
        else
        {
            // Right aligned points
            addPoint(right - 0.03, point.y);
            addPoint(right - 0.02, point.y);
            addPoint(right - 0.01, point.y);
        }
    }

    // Add points from array to path
    CGPoint node = ((NSValue *)[points objectAtIndex:0]).CGPointValue;
    if (path.isEmpty)
    {
        [path moveToPoint:node];
    }
    else
    {
        [path addLineToPoint:node];
    }
    for (int i=1; i<points.count; i++)
    {
        node = ((NSValue *)[points objectAtIndex:i]).CGPointValue;
        [path addLineToPoint:node];
    }

    // Add last point of not replaced
    if (!hasCustomLastPoint)
    {
        [path addLineToPoint:CGPointMake(right, point.y)];
    }
}

- (void)handleSelect:(UIGestureRecognizer *)gestureRecognizer
{
    NSUInteger index = [self._items indexOfObject:gestureRecognizer.view];
    if (index != NSNotFound && index != self.selectedSegmentIndex)
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

    CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, -.5, -.5) cornerRadius:self.layer.cornerRadius].CGPath;
    CGContextAddPath(context, roundedRect);
    CGContextClip(context);

    CGContextAddPath(context, roundedRect);
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, .5), 2.5, UIColor.blackColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.backgroundColor.CGColor);
    CGContextStrokePath(context);
}

@end
