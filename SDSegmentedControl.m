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
const CGFloat kSDSegmentedControlInterItemSpace = 30.0;
const UIEdgeInsets kSDSegmentedControlStainEdgeInsets = {-2, -16, -4, -16};
const CGSize kSDSegmentedControlImageSize = {18, 18};

const CGFloat kSDSegmentedControlScrollOffset = 20;


@interface SDSegmentView (Private)

- (CGRect)innerFrame;

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
    BOOL _isScrollingBySelection;
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
    // Default height
    CGRect frame = self.frame;
    frame.size.height = 43;
    self.frame = frame;

    // Init properties
    _lastSelectedSegmentIndex = -1;
    _selectedSegmentIndex = -1;
    _borderColor = UIColor.whiteColor;
    _arrowHeightFactor = -1.0;
    _interItemSpace = kSDSegmentedControlInterItemSpace;
    _stainEdgeInsets = kSDSegmentedControlStainEdgeInsets;
    __items = NSMutableArray.new;

    // Appearance properties
    _animationDuration = kSDSegmentedControlDefaultDuration;
    _arrowSize = kSDSegmentedControlArrowSize;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    // Reset UIKit original widget
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // Init layer
    self.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    self.layer.backgroundColor = UIColor.clearColor.CGColor;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowRadius = .8;
    self.layer.shadowOpacity = .6;
    self.layer.shadowOffset = CGSizeMake(0, 1);

    // Init border bottom layer
    [self.layer addSublayer:_borderBottomLayer = CAShapeLayer.layer];
    _borderBottomLayer.strokeColor = _borderColor.CGColor;
    _borderBottomLayer.lineWidth = .5;
    _borderBottomLayer.fillColor = nil;
    [self.layer addSublayer:_borderBottomLayer];

    // Init scrollView
    [self addSubview:_scrollView = UIScrollView.new];
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.backgroundColor = UIColor.clearColor;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;

    // Init stain view
    [_scrollView addSubview:self._selectedStainView = SDStainView.new];
    self._selectedStainView.backgroundColor = [UIColor colorWithWhite:0.816 alpha:1];
}

- (UIColor *)backgroundColor
{
    return [UIColor colorWithCGColor:((CAShapeLayer *)self.layer).fillColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    ((CAShapeLayer *)self.layer).fillColor = backgroundColor.CGColor;
}

#pragma mark - UIKit API

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self insertSegmentWithTitle:nil image:image atIndex:index animated:animated];
}

- (UIImage *)imageForSegmentAtIndex:(NSUInteger)index
{
    return [[self segmentAtIndex:index] imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)index
{
    SDSegmentView* segmentView = [self segmentAtIndex:index];
    [segmentView setImage:image forState:UIControlStateNormal];
    [segmentView sizeToFit];
    [self setNeedsLayout];
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)index
{
    index = MAX(MIN(index, self.numberOfSegments - 1), 0);
    UIButton *segmentView = self._items[index];
    [segmentView setTitle:title forState:UIControlStateNormal];
    [segmentView sizeToFit];
    [self setNeedsLayout];
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)index
{
    index = MAX(MIN(index, self.numberOfSegments - 1), 0);
    UIButton *segmentView = self._items[index];
    return [segmentView titleForState:UIControlStateNormal];
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self insertSegmentWithTitle:title image:nil atIndex:index animated:animated];
}

- (void)removeSegmentAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (self._items.count == 0) return;
    index = MAX(MIN(index, self.numberOfSegments - 1), 0);
    UIView *segmentView = self._items[index];
    [self._items removeObject:segmentView];

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
            self.selectedSegmentIndex = [self firstEnabledSegmentIndexNearIndex:self.selectedSegmentIndex];
        }
        else if (self.selectedSegmentIndex > index)
        {
            self.selectedSegmentIndex = [self firstEnabledSegmentIndexNearIndex:self.selectedSegmentIndex - 1];
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

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)index
{
    [self segmentAtIndex:index].enabled = enabled;

    if (index == self.selectedSegmentIndex)
    {
        self.selectedSegmentIndex = [self firstEnabledSegmentIndexNearIndex:index];
    }
}

- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)index
{
    return  [self segmentAtIndex:index].enabled;
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

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)index
{
    SDSegmentView *segmentView = [self segmentAtIndex:index];
    CGRect frame = segmentView.frame;
    frame.size.width = width;
    segmentView.frame = frame;
    [self setNeedsLayout];
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)index
{
    return CGRectGetWidth([self segmentAtIndex:index].frame);
}

# pragma mark - Private

- (void)insertSegmentWithTitle:(NSString *)title image:(UIImage *)image atIndex:(NSUInteger)index animated:(BOOL)animated
{
    SDSegmentView *segmentView = SDSegmentView.new;
    [segmentView addTarget:self action:@selector(handleSelect:) forControlEvents:UIControlEventTouchUpInside];
    segmentView.alpha = 0;
    [segmentView setTitle:title forState:UIControlStateNormal];
    [segmentView setImage:image forState:UIControlStateNormal];
    [segmentView sizeToFit];

    index = MAX(MIN(index, self.numberOfSegments), 0);
    if (index < self._items.count)
    {
        segmentView.center = ((UIView *)self._items[index]).center;
        [self.scrollView insertSubview:segmentView belowSubview:self._items[index]];
        [self._items insertObject:segmentView atIndex:index];
    }
    else
    {
        segmentView.center = self.center;
        [self.scrollView addSubview:segmentView];
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

- (NSInteger)firstEnabledSegmentIndexNearIndex:(NSUInteger)index
{
    // Select the first enabled segment
    for (int i = index; i < self._items.count; i++)
    {
        if (((SDSegmentView *)self._items[i]).enabled)
        {
            return i;
        }
    }

    for (int i = index; i >= 0; i--)
    {
        if (((SDSegmentView *)self._items[i]).enabled)
        {
            return i;
        }
    }

    return -1;
}

- (SDSegmentView *)segmentAtIndex:(NSUInteger)index
{
    NSParameterAssert(index >= 0 && index < self._items.count);
    return self._items[index];
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

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderBottomLayer.strokeColor = borderColor.CGColor;
    _borderColor = borderColor;
}

- (void)setArrowSize:(CGFloat)arrowSize
{
    _arrowSize = arrowSize;
    [self setNeedsLayout];
}


- (void)setArrowHeightFactor:(CGFloat)arrowHeightFactor
{
    _arrowHeightFactor = arrowHeightFactor;
    [self setNeedsLayout];
}


- (void)layoutSubviews
{
    self.scrollView.frame = self.bounds;
    [self layoutSegments];
}

- (void)layoutSegments
{
    CGFloat totalItemWidth = 0;
    for (SDSegmentView *item in self._items)
    {
        totalItemWidth += CGRectGetWidth(item.bounds);
    }

    CGFloat totalWidth = (totalItemWidth + (self.interItemSpace * (self.numberOfSegments - 1)));

    // Apply total to scrollView
    __block CGFloat currentItemPosition = 0;
    CGSize contentSize = self.scrollView.contentSize;
    if (totalWidth > self.bounds.size.width)
    {
        // We must scroll, so add an offset
        totalWidth += 2 * kSDSegmentedControlScrollOffset;
        currentItemPosition += kSDSegmentedControlScrollOffset;
        contentSize.width = totalWidth;
    }
    else
    {
        contentSize.width = CGRectGetWidth(self.bounds);
    }
    contentSize.height = self.bounds.size.height;
    self.scrollView.contentSize = contentSize;

    // Center all items horizontally and each item vertically
    CGFloat spaceLeft = self.scrollView.contentSize.width - totalWidth;
    CGFloat itemHeight = self.scrollView.contentSize.height - self.arrowSize / 2 + .5;

    currentItemPosition += spaceLeft / 2;
    [self._items enumerateObjectsUsingBlock:^(SDSegmentView *item, NSUInteger idx, BOOL *stop)
    {
        item.alpha = 1;
        item.frame = CGRectIntegral(CGRectMake(currentItemPosition, 0, CGRectGetWidth(item.bounds), itemHeight));
        currentItemPosition = CGRectGetMaxX(item.frame) + self.interItemSpace;
    }];

    // Layout stain view and update items
    BOOL animated = self.animationDuration && !CGRectEqualToRect(self._selectedStainView.frame, CGRectZero);
    BOOL isScrollingSinceNow = NO;
    CGFloat selectedItemCenterPosition;

    if (self.selectedSegmentIndex == -1)
    {
        self._selectedStainView.hidden = YES;
        selectedItemCenterPosition = CGFLOAT_MAX;
        for (SDSegmentView *item in self._items)
        {
            item.selected = NO;
        }
    }
    else
    {
        SDSegmentView *selectedItem = self._items[self.selectedSegmentIndex];
        selectedItemCenterPosition = selectedItem.center.x;

        CGRect stainFrame = UIEdgeInsetsInsetRect(selectedItem.innerFrame, self.stainEdgeInsets);
        self._selectedStainView.layer.cornerRadius = CGRectGetHeight(stainFrame) / 2;
        self._selectedStainView.hidden = NO;
        stainFrame.origin.x = roundf(selectedItemCenterPosition - CGRectGetWidth(stainFrame) / 2);
        selectedItemCenterPosition -= self.scrollView.contentOffset.x;

        if (self.scrollView.contentSize.width > self.scrollView.bounds.size.width)
        {
            CGRect scrollRect = {self.scrollView.contentOffset, self.scrollView.bounds.size};
            CGRect targetRect = CGRectInset(stainFrame, -kSDSegmentedControlScrollOffset / 2, 0);

            if (!CGRectContainsRect(scrollRect, targetRect))
            {
                // Adjust position
                CGFloat posOffset = 0;
                if (CGRectGetMinX(targetRect) < CGRectGetMinX(scrollRect))
                {
                    posOffset += CGRectGetMinX(scrollRect) - CGRectGetMinX(targetRect);
                }
                else if (CGRectGetMaxX(targetRect) > CGRectGetMaxX(scrollRect))
                {
                    posOffset -= CGRectGetMaxX(targetRect) - CGRectGetMaxX(scrollRect);
                }

                // Recenter arrow with posOffset
                selectedItemCenterPosition += posOffset;

                // Temporary disable updates, if scrolling is needed, because scrollView will cause a
                // lot of relayouts. The field isScrollBySelection will be reseted by scrollView's delegate
                // call to scrollViewDidEndScrollingAnimation and can't be resetted after called, because
                // the animation is dispatched asynchronously, naturally.
                _isScrollingBySelection = animated;
                isScrollingSinceNow = YES;
                [self.scrollView scrollRectToVisible:targetRect animated:animated];
            }
        }

        UIView.animationsEnabled = animated;
        [UIView animateWithDuration:animated ? self.animationDuration : 0 animations:^
        {
            self._selectedStainView.frame = stainFrame;
        }
        completion:^(BOOL finished)
        {
            for (SDSegmentView *item in self._items)
            {
                item.selected = item == selectedItem;
            }
        }];
        UIView.animationsEnabled = YES;
    }

    // Don't relayout paths while scrolling
    if (!_isScrollingBySelection || isScrollingSinceNow)
    {
        // Animate from a custom oldPosition if needed
        CGFloat oldPosition = CGFLOAT_MAX;
        if (animated && _lastSelectedSegmentIndex != self.selectedSegmentIndex && _lastSelectedSegmentIndex >= 0 && _lastSelectedSegmentIndex < self._items.count)
        {
            SDSegmentView *lastSegmentView = [self._items objectAtIndex:_lastSelectedSegmentIndex];
            oldPosition = lastSegmentView.center.x - self.scrollView.contentOffset.x;
        }

        [self drawPathsFromPosition:oldPosition toPosition:selectedItemCenterPosition animationDuration:animated ? self.animationDuration : 0];
    }
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
    NSString *camelCaseKeyPath;
    NSString *keyPath;

    if ([key isEqual:@"path"])
    {
        camelCaseKeyPath = key;
        keyPath = key;
    }
    else
    {
        camelCaseKeyPath = [NSString stringWithFormat:@"%@Path", key];
        keyPath = [NSString stringWithFormat:@"%@.path", key];
    }

    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:camelCaseKeyPath];
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
    const CGFloat ratio = self.arrowHeightFactor;

    __block NSMutableArray *points = NSMutableArray.new;
    BOOL hasCustomLastPoint = NO;

    void (^addPoint)(CGFloat x, CGFloat y) = ^(CGFloat x, CGFloat y)
    {
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    };

    // Add first point
    addPoint(left, point.y);

    if (_arrowSize <= 0.02)
    {
        addPoint(point.x - lineWidth, point.y);
        addPoint(point.x,             point.y);
        addPoint(point.x + lineWidth, point.y);
    }
    else if (point.x >= left+width && point.x <= right-width)
    {
        // Arrow is completely inside the view
        addPoint(point.x - width, point.y);
        addPoint(point.x,         point.y + ratio * height);
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
                addPoint(left,        point.y + ratio * x);
                addPoint(left + 0.01, point.y + ratio * (x + 0.01));
                addPoint(left + 0.02, point.y + ratio * (x + 0.02));
                addPoint(left + x,    point.y);
            }
            else
            {
                CGFloat x = width - point.x;
                addPoint(left,            point.y + ratio * x);
                addPoint(left + 0.01,     point.y + ratio * (x + 0.01));
                addPoint(point.x,         point.y + ratio * height);
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
                addPoint(point.x,         point.y + ratio * height);
                addPoint(right - 0.01,    point.y + ratio * (x + 0.01));
                addPoint(right,           point.y + ratio * x);
            }
            else
            {
                CGFloat x = width + (right - point.x);
                addPoint(right - x,    point.y);
                addPoint(right - 0.02, point.y + ratio * (x + 0.02));
                addPoint(right - 0.01, point.y + ratio * (x + 0.01));
                addPoint(right,        point.y + ratio * x);
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

- (void)handleSelect:(SDSegmentView *)view
{
    NSUInteger index = [self._items indexOfObject:view];
    if (index != NSNotFound && index != self.selectedSegmentIndex)
    {
        self.selectedSegmentIndex = index;
        [self setNeedsLayout];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isScrollingBySelection) return;
    CGFloat selectedItemCenterPosition = ((SDSegmentView *)self._items[self.selectedSegmentIndex]).center.x;
    [self drawPathsToPosition:selectedItemCenterPosition - scrollView.contentOffset.x animated:NO];
    self._selectedStainView.center = CGPointMake(selectedItemCenterPosition, self._selectedStainView.center.y);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isScrollingBySelection = NO;
}

@end


@implementation SDSegmentView

+ (void)initialize
{
    [super initialize];

    SDSegmentView *appearance = [self appearance];
    [appearance setTitleColor:[UIColor colorWithWhite:0.392 alpha:1] forState:UIControlStateNormal];
    [appearance setTitleShadowColor:UIColor.whiteColor forState:UIControlStateNormal];

    [appearance setTitleColor:[UIColor colorWithWhite:0.235 alpha:1] forState:UIControlStateSelected];
    [appearance setTitleShadowColor:UIColor.whiteColor forState:UIControlStateSelected];

    [appearance setTitleColor:[UIColor colorWithWhite:0.800 alpha:1] forState:UIControlStateDisabled];
    [appearance setTitleShadowColor:UIColor.clearColor forState:UIControlStateDisabled];

    [appearance setItemFont:[UIFont boldSystemFontOfSize:14]];
}

+ (SDSegmentView *)new
{
    return [self.class buttonWithType:UIButtonTypeCustom];
}

+ (id)appearance
{
    return [self appearanceWhenContainedIn:SDSegmentedControl.class, nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _imageSize = kSDSegmentedControlImageSize;
        self.titleLabel.shadowOffset = CGSizeMake(0, 0.5);
        self.userInteractionEnabled = YES;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0, -8.0); // Space between text and image
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0, 0.0); // Space between image and stain
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0, 8.0); // Enlarge touchable area

#ifdef SDSegmentedControlDebug
        self.backgroundColor = [UIColor colorWithHue:1.00 saturation:1.0 brightness:1.0 alpha:0.5];
        self.imageView.backgroundColor = [UIColor colorWithHue:0.66 saturation:1.0 brightness:1.0 alpha:0.5];
        self.titleLabel.backgroundColor = [UIColor colorWithHue:0.33 saturation:1.0 brightness:1.0 alpha:0.5];
#endif
    }
    return self;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:[self scaledImageWithImage:image] forState:state];
}

- (UIImage *)scaledImageWithImage:(UIImage*)image
{
    if (!image) return nil;

    // Scale down images that are too large 
    if (image.size.width > self.imageSize.width || image.size.height > self.imageSize.height)
    {
        UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, self.imageSize.width, self.imageSize.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 0.0);
        [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

	return image;

}

- (CGRect)innerFrame
{
    const CGPoint origin = self.frame.origin;
    CGRect innerFrame = CGRectOffset(self.titleLabel.frame, origin.x, origin.y);

    if (innerFrame.size.width > 0)
    {
        innerFrame.size.width = self.titleEdgeInsets.left + self.titleLabel.frame.size.width + self.titleEdgeInsets.right;
    }

    if ([self imageForState:self.state])
    {
        const CGRect imageViewFrame = self.imageView.frame;
        if (innerFrame.size.height > 0)
        {
            innerFrame.origin.y -= (imageViewFrame.size.height - innerFrame.size.height) / 2;
        }
        else
        {
            innerFrame.origin.y = imageViewFrame.origin.y;
        }
        innerFrame.size.height = imageViewFrame.size.height;
        innerFrame.size.width += self.imageEdgeInsets.left + imageViewFrame.size.width + self.imageEdgeInsets.right;
    }

    return innerFrame;
}

- (void)setItemFont:(UIFont *)itemFont
{
    self.titleLabel.font = itemFont;
}

- (UIFont *)itemFont
{
    return self.titleLabel.font;
}

@end


@implementation SDStainView

+ (void)initialize
{
    [super initialize];
    SDStainView *appearance = [self appearance];
    appearance.edgeInsets = UIEdgeInsetsMake(-.5, -.5, -.5, -.5);
    appearance.shadowOffset = CGSizeMake(0, .5);
    appearance.shadowBlur = 2.5;
    appearance.shadowColor = UIColor.blackColor;
    appearance.innerStrokeLineWidth = 1.5;
    appearance.innerStrokeColor = UIColor.whiteColor;
}

+ (id)appearance
{
    return [self appearanceWhenContainedIn:SDSegmentedControl.class, nil];
}

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

    CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets) cornerRadius:self.layer.cornerRadius].CGPath;
    CGContextAddPath(context, roundedRect);
    CGContextClip(context);

    CGContextAddPath(context, roundedRect);
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.backgroundColor.CGColor);
    CGContextStrokePath(context);

    CGContextTranslateCTM(context, 0, -1);
    CGContextAddPath(context, roundedRect);
    CGContextSetLineWidth(context, self.innerStrokeLineWidth);
    CGContextSetStrokeColorWithColor(context, self.innerStrokeColor.CGColor);
    CGContextStrokePath(context);
}

@end
