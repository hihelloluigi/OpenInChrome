# Opening links in Chrome for iOS (Swift Version)
This repo is a rewritten version of Google's [OpenInChrome](https://github.com/GoogleChrome/OpenInChrome) in Swift language. The `OpenInChromeController` class is kept identical to the original one. Refer to the [original documentation](https://github.com/GoogleChrome/OpenInChrome/blob/master/README.md) for details.

## Requirements ##
* Xcode 10 (Swift 4.2)

## Downloading the class file ##
The OpenInChromeController class file is available [here](https://github.com/mo3bius/OpenInChrome/blob/master/OpenInChromeDemo/OpenInChromeController.swift). Copy it into your Xcode installation.

## Usage ##

Add this to your application's Info.plist
```
  <key>LSApplicationQueriesSchemes</key>
	<array>
		<string>googlechrome</string>
		<string>googlechromes</string>
		<string>googlechrome-x-callback</string>
	</array>
 ```

Use the OpenInChromeController class as follows:
```
if OpenInChromeController.shared.isChromeInstalled() {
  try OpenInChromeController.shared.openInChrome(URL(string: link)!, callbackURL: nil, createNewTab: false, completionHandler: nil)
}
```