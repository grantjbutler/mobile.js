# mobile.js

mobile.js allows you to build iOS applications using only JavaScript.

Like Ejecta, mobile.js is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).

**NOTE: This is very much in an alpha state. Not much has been implemented, as this is mostly in a "proof of concept" phase currently.**

## How does this differ from PhoneGap?

PhoneGap is basically a wrapper around a web browser with a couple tie-ins to the device's hardware. You are required to build the UI yourself either from scratch, or using a library such as jQuery Mobile. As a result, you don't get the performance you would normally get from a standard iOS application, nor do you get the full experience of an iOS application.

mobile.js differs by stripping out the HTML and CSS component of it and just has JavaScript bindings directly to Objective-C code by using WebKit's JavaScriptCore engine. Now, you don't write the UI code. All of that is backed by native UI elements in Objective-C, resulting in a better app experience, and better performance.

## How does mobile.js work?

mobile.js borrows a lot of base code from [Ejecta](https://github.com/phoboslab/Ejecta/) to get the Javascript->Objective-C bindings to work, as well as a compiled version of the JavaScriptCore framework. From there, base code is implemented that adds some of the usual JavaScript properties and methods, including `console`, `navigator`, and others. On top of that is higher level bindings to the Foundation and UIKit frameworks. From there, other framework bindings can be added, including a mirror to the Canvas API on top of CoreGraphics, and the Web Audio API on top of CoreAudio.

## Words of Warning

This is the first time I've played with JavaScriptCore. I'm probably doing a lot of things I shouldn't be. I'm doing research to see if there are right ways about doing things, but if you know for a fact that I'm doing something wrong, and can fix it, by all means, fork it, make the change, and submit a pull request.
