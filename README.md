# Inter-App Communication (Swift)

## x-callback-url made easy

Inter-App Communication, **IAC** from now on, is a framework that allows your iOS app to communicate, very easily, with other iOS apps installed in the device that supports the [**x-callback-url**](http://x-callback-url.com/) protocol. With **IAC** you can also add an **x-callback-url** **API** to your app in a very easy and intuitive way.

**IAC** currently supports the **x-callback-url** [1.0 DRAFT specification](http://x-callback-url.com/specifications/).

This is the swift version of the original in Objective-C available [here](https://github.com/tapsandswipes/InterAppCommunication.git)

## Usage

### Call external app

From anywhere in your app you can call any external app on the device with the following code

```swift
import IACCore

let client = IACClient(scheme: "appscheme")
client.performAction("action" parameters: ["param1": "value1", "param2": "value2"])
```


You can also use, if available, client subclasses for the app you are calling. Within the framework there are clients for Instapaper and Google Chrome and many more will be added in the future. 

For example, to add a url to Instapaper from your app, you can do:

* Without specific client class:

```swift
import IACCore

let client = IACClient(scheme: "x-callback-instapaper")
client.performAction("add", parameters: ["url": "http://tapsandswipes.com"])
```

* With the client class specific for Instapaper:

```swift
import IACClients

InstapaperIACClient().add("http://tapsandswipes.com")
```


### Receive callbacks from the external app

If you want to be called back from the external app you can specify success and failure handler blocks, for example:

```swift
let client = IACClient(scheme: "appscheme")
client.performAction("action",
            parameters:["param1": "value1", "param2": "value2"],
            handler: { result in 
                switch result {
                case .success(let data):
                    print("OK: \(data)")
                case .cancelled:
                    print("Canceller")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
)
```

 
For the callbacks to work, your app must support the **x-callback-url** protocol. The easiest way is to let **IAC** manage that.

### Add x-callback-url support to your app

Follow these simple steps to add **x-callback-url** support to your app:

1. Define the url scheme that your app will respond to in the `Info.plist` of your app. See the section **Implementing Custom URL Schemes** in [this article](http://developer.apple.com/library/ios/#DOCUMENTATION/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html#//apple_ref/doc/uid/TP40007072-CH7-SW50).
 
2. Assign this scheme to the IACManager instance with `IACManager.shared.callbackURLScheme = "myappscheme"`. I recommend doing this in the delegate method `application(_: , didFinishLaunchingWithOptions: )`

3. Call `handleOpenURL(_:)` from the URL handling method in the app`s delegate. For example:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
    return IACManager.shared.handleOpenURL(url)
}
```

With these three steps your app will be available to call other apps and receive callbacks from them.

### Add an x-callback-url API to your app

If you want to add an external **API** to your app through the **x-callback-url** protocol you can use any of these two options or both:

- Add handler blocks for your actions directly to the `IACManager` instance calling `handleAction(_:, with:)` for each action.

- Implement the `IACDelegate` protocol in any of your classes and assign the delegate to the `IACManager` instance, preferably in the app delegate `application(_:, didFinishLaunchingWithOptions:)` method.

Action handlers take precedence over the delegate for the same action.

Explore the sample code to see all of these in place.



## Installation

#### Via [Swift Package Manager](https://github.com/apple/swift-package-manager)

1. Add `.Package(url: "https://github.com/tapsandswipes/Inter-AppCommunication.git", branch: "main")` to your `Package.swift` inside `dependencies`:
```swift
import PackageDescription

let package = Package(
	name: "yourapp",
	dependencies: [
		.Package(url: "https://github.com/tapsandswipes/Inter-AppCommunication.git", branch: "main")
 	]
)
```
2. Run `swift build`.
 
#### Manual
 
You can also install it manually by copying to your project the contents of the directory `Sources/IACCore`.

Within the directory `Sources/IACClients` you can find clients for some apps, copy the files for the client you want to use to your project. 



## Create an IAC client class for your app

If you have an app that already have an x-callback-url API, you can help other apps to communicate with your app by creating an `IACClient` subclass and share these classes with them.

This way you can implement the exposed API as if the app were an internal component within the caller app. You can implement the methods with the required parameters and even make some validation before the call is made.

Inside the `Sources/IACClients` directory you can find all the client subclasses currently implemented. If you have implemented one for your own app, do not hesitate to contact me and I will add it to the repository. 



## Contact

- [Personal website](http://tapsandswipes.com)
- [GitHub](http://github.com/tapsandswipes)
- [Twitter](http://twitter.com/acvivo)
- [LinkedIn](http://www.linkedin.com/in/acvivo)
- [Email](mailto:antonio@tapsandswipes.com)

If you use/enjoy Inter-app Communication framework, let me know!



## License

### MIT License

Copyright (c) 2013 Antonio Cabezuelo Vivo (http://tapsandswipes.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
