# MRARViewDebugger

[![CI Status](http://img.shields.io/travis/mattrobmattrob/MRARViewDebugger.svg?style=flat)](https://travis-ci.org/mattrobmattrob/MRARViewDebugger)
[![Version](https://img.shields.io/cocoapods/v/MRARViewDebugger.svg?style=flat)](http://cocoapods.org/pods/MRARViewDebugger)
[![License](https://img.shields.io/cocoapods/l/MRARViewDebugger.svg?style=flat)](http://cocoapods.org/pods/MRARViewDebugger)
[![Platform](https://img.shields.io/cocoapods/p/MRARViewDebugger.svg?style=flat)](http://cocoapods.org/pods/MRARViewDebugger)

MRARViewDebugger allows in place view hierarchy visualization of `UIViewController`s using ARKit.
The user is given the ability to separate layers by variable distances and scrub through the stack
using a slider similar to what Apple provides in Xcode's built in view debugger.

Debug your views on the device when something goes wrong vs. having to deal with reproducing and/or
attaching to the process in Xcode.

## Requirements

- ARKit
- iOS 11

## Installation

MRARViewDebugger is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MRARViewDebugger"
```

Present the view debugger like this (to be called from a `UIViewController`):
```objc
MRARViewDebuggerViewController *viewController = [[MRARViewDebuggerViewController alloc] initWithViewController:self];
[self presentViewController:viewController animated:YES completion:nil];
```

## Playing around

1. Open `Example/MRARViewDebugger.xcworkspace`
2. Run the target on an iOS 11 device that supports ARKit
3. Tap on surface once they are visualized
4. Walk around view debugger 🎉

## Author

@mattrobmattrob or [@m4ttrob](https://twitter.com/m4ttrob)

## License

MRARViewDebugger is available under the MIT license. See the LICENSE file for more info.
