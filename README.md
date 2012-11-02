# Segmented Control

A drop-in remplacement for UISegmentedControl that mimic iOS 6 AppStore tab
controls.

![The only good piece of UI to extract for this terrible app](https://raw.github.com/rs/SDSegmentedControl/master/Screenshots/screenshot-1.png)

## Features:

- Segments with image, image and text or text only
- Interface Builder support (just throw a UISegmentedControl and change
  its class SDSegmentedControl)
- Animated segment selection
- Content aware dynamic segment width
- Animated segment selection, with animated arrow
- Appearance customization thru UIAppearance
- UIControl events for value changes

## TODO:

- Disabled state
- Custom segment width
- Horizontal scrolling when tabs don't fit

# Usage

Import `SDSegmentedControl.h` and `SDSegmentedControl.m` into your
project and add `QuartzCore` framework to `Build Phases` -> `Link Binary With
Libraries`.

You can then use `SDSegmentedControl` class as you would use normal
`UISegmentedControl`.

# Known Issues

The background mask doesn't animate when resized. If someone has a solution for
this, please send a pull request.
