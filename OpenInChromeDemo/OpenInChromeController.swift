// Copyright (c) 2019 Luigi Aiello
//
// Copyright 2012, Google Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import UIKit

private let googleChromeHTTPScheme: String = "googlechrome:"
private let googleChromeHTTPSScheme: String = "googlechromes:"
private let googleChromeCallbackScheme: String = "googlechrome-x-callback:"

private func encodeByAddingPercentEscapes(_ input: String?) -> String {
    return input!.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]"))!
}

private enum OpenInChromeError: Error {
    case urlSchemaNotValid
    case urlNotValid
    case outOfStock
}

open class OpenInChromeController {
    
    // MARK: - Variables
    var appName: String? {
        var localName: String?
        
        if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            localName = name
        } else if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            localName = name
        }
        
        return localName
    }
    
    // MARK: - Singleton
    public static let shared = OpenInChromeController()
    
    open func isChromeInstalled() -> Bool {
        guard
            let simpleURL = URL(string: googleChromeHTTPScheme),
            let callbackURL = URL(string: googleChromeCallbackScheme)
        else {
            return false
        }
        
        return UIApplication.shared.canOpenURL(simpleURL) || UIApplication.shared.canOpenURL(callbackURL)
    }
    
    @available(*, deprecated: 10.0, message: "Use open in Chrome with completionHandler")
    open func openInChrome(_ url: URL, callbackURL: URL? = nil, createNewTab: Bool = false) throws {
        try localOpenInChrome(url, callbackURL: callbackURL, createNewTab: createNewTab)
    }
    
    @available(iOS 10.0, *)
    open func openInChrome(_ url: URL, callbackURL: URL? = nil, createNewTab: Bool = false, completionHandler: ((Bool) -> Void)? = nil) throws {
        try localOpenInChrome(url, callbackURL: callbackURL, createNewTab: createNewTab, completionHandler: completionHandler)
    }
    
    private func localOpenInChrome(_ url: URL, callbackURL: URL? = nil, createNewTab: Bool = false, completionHandler: ((Bool) -> Void)? = nil) throws {
        guard
            let chromeSimpleURL = URL(string: googleChromeHTTPScheme),
            let chromeCallbackURL = URL(string: googleChromeCallbackScheme)
        else {
            assertionFailure("Google Chrome Scheme are not set")
            return
        }
        
        if UIApplication.shared.canOpenURL(chromeCallbackURL) {
            guard let appName = appName else {
                assertionFailure("I cannot find app name")
                return
            }
            
            guard try checkSchema(url.scheme?.lowercased()) != nil else {
                return
            }
            
            var chromeURLString = String(format: "%@//x-callback-url/open/?x-source=%@&url=%@",
                                         googleChromeCallbackScheme,
                                         encodeByAddingPercentEscapes(appName),
                                         encodeByAddingPercentEscapes(url.absoluteString))
            
            if callbackURL != nil {
                chromeURLString += String(format: "&x-success=%@", encodeByAddingPercentEscapes(callbackURL!.absoluteString))
            }
            if createNewTab {
                chromeURLString += "&create-new-tab"
            }
            
            try genericOpenUrl(chromeURLString, completionHandler: completionHandler)
        } else if UIApplication.shared.canOpenURL(chromeSimpleURL) {
            guard let scheme = try checkSchema(url.scheme?.lowercased()) else {
                return
            }
            
            let absoluteURLString = url.absoluteString
            let chromeURLString = scheme + absoluteURLString[..<absoluteURLString.range(of: ":")!.lowerBound]
            
            try genericOpenUrl(chromeURLString, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Helpers
    private func checkSchema(_ scheme: String?) throws -> String? {
        guard let scheme = scheme else {
            return nil
        }
        
        var localScheme: String = ""
        
        if scheme == "http" {
            localScheme = googleChromeHTTPScheme
        } else if scheme == "https" {
            localScheme = googleChromeHTTPSScheme
        } else {
            throw OpenInChromeError.urlSchemaNotValid
        }
        
        return localScheme
    }
    
    private func genericOpenUrl(_ string: String?, completionHandler: ((Bool) -> Void)? = nil) throws {
        guard
            let urlString = string,
            let url = URL(string: urlString)
        else {
            throw OpenInChromeError.urlNotValid
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: completionHandler)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
