//
//  MediaItem.swift
//  Smashtag
//
//  Created by Yoanna Mareva on 4/22/16.
//  Copyright © 2016 Yoanna Mareva. All rights reserved.
//

import Foundation

public struct MediaItem {
    public var url: NSURL!
    public var aspectRatio: Double = 0
    
    public var description: String {
        return (url.absoluteString ?? "no url") + "(aspect ratio = \(aspectRatio))"
    }
    
    //MARK: Private implementation
    
    init?(data: NSDictionary?) {
        var valid = false
        if let urlString = data?.valueForKeyPath(TwitterKey.MediaURL) as? NSString {
            if let url = NSURL(string: urlString as String) {
                self.url = url
                let h = data?.valueForKeyPath(TwitterKey.Height) as? NSNumber
                let w = data?.valueForKeyPath(TwitterKey.Width) as? NSNumber
                if h != nil && w != nil {
                    aspectRatio = w!.doubleValue / h!.doubleValue
                    valid = true
                }
            }
        }
    }
    
    struct TwitterKey {
        static let MediaURL = "media_url_https"
        static let Width = "sizes.small.w"
        static let Height = "sizes.small.h"
    }
}