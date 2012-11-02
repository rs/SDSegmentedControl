# Segmented Control

A drop-in remplacement for UISegmentedControl that mimic iOS 6 AppStore tab
controls.

<iframe frameborder="0" width="320" height="404" src="http://www.dailymotion.com/embed/video/xusly6?autoplay=1&related=0&info=0"></iframe>

## Features:

- Segments with image, image and text or text only
- Interface Builder support (just throw a UISegmentedControl and change
  its class SDSegmentedControl)
- Animated segment selection
- Content aware dynamic segment width
- Scrollable if there are too many segments for width
- Animated segment selection, with animated arrow
- Appearance customization thru UIAppearance
- UIControl events for value changes
- Enable or disable specific segments

## TODO:

- Custom segment width

# Usage

Import `SDSegmentedControl.h` and `SDSegmentedControl.m` into your
project and add `QuartzCore` framework to `Build Phases` -> `Link Binary With
Libraries`.

You can then use `SDSegmentedControl` class as you would use normal
`UISegmentedControl`.

# Known Issues

The background mask doesn't animate when resized. If someone has a solution for
this, please send a pull request.
