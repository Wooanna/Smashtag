//
//  Tweet.swift
//  Smashtag
//
//  Created by Yoanna Mareva on 4/22/16.
//  Copyright © 2016 Yoanna Mareva. All rights reserved.
//

import Foundation

public class Tweet : CustomStringConvertible
{
    public var text: String
    public var user: User
    public let created: NSDate
    public let id: String?
    public var media = [MediaItem] ()
    public var mediaMentions = [IndexedKeyword] ()
    public var hashtags = [IndexedKeyword] ()
    public var urls = [IndexedKeyword] ()
    public var userMentions = [IndexedKeyword] ()
    
    public struct IndexedKeyword: CustomStringConvertible
    {
        public var keyword: String
        public var range: Range<String.Index>
        public var nsrange = NSMakeRange(0, 0)
        
        public init?(data: NSDictionary?, inText: String, prefix: String?) {
            let indices = data?.valueForKeyPath(TwitterKey.Entities.Indices) as? NSArray
            if let startIndex = (indices?.firstObject as? NSNumber)?.integerValue {
                if let endIndex = (indices?.lastObject as? NSNumber)?.integerValue {
                    let length = inText.characters.count
                    if length > 0 {
                        let start = max(min(startIndex, length-1), 0)
                        let end = max(min(endIndex, length), 0)
                        if end > start {
                            range = inText.startIndex.advancedBy(start)...inText.startIndex.advancedBy(end-1)
                            keyword = inText.substringWithRange(range)
                            if prefix != nil && !keyword.hasPrefix(prefix!) && start > 0 {
                                range = inText.startIndex.advancedBy(start-1)...inText.startIndex.advancedBy(end-2)
                                keyword = inText.substringWithRange(range)
                            }
                            if prefix == nil || keyword.hasPrefix(prefix!) {
                                nsrange = inText.rangeOfString(keyword, nearRange: NSMakeRange(startIndex, endIndex-startIndex))
                                if nsrange.location != NSNotFound {
                                    return
                                }
                            }
                        }
                    }
                }
            }
            return nil
        }
        
        public var description : String {
            get {
                return "\(keyword) (\(nsrange.location), \(nsrange.location + nsrange.length-1))"
            }
        }
    }
    
    public var description: String{
        return "\(user) - \(created)\n\(text)\nhashtags: \(hashtags)\nurls: \(urls)\nuser_mentions: \(userMentions)" + (id == nil ? "" : "\nid: \(id)")
    }
    
    init?(data: NSDictionary?) {
        if let user = User(data: data?.valueForKey(TwitterKey.User) as? NSDictionary) {
            self.user = user
            if let text = data?.valueForKeyPath(TwitterKey.Text) as? String {
                self.text = text
                if let created = (data?.valueForKeyPath(TwitterKey.Created) as? String)?.asTwitterDate {
                    self.created = created
                    id = data?.valueForKeyPath(TwitterKey.ID) as? String
                    if let mediaEntities = data?.valueForKeyPath(TwitterKey.Media) as? NSArray {
                        for mediaData in mediaEntities {
                            if let mediaItem = MediaItem(data: mediaData as? NSDictionary) {
                                media.append(mediaItem)
                            }
                        }
                        mediaMentions = getIndexedKeywords(mediaEntities, inText: text, prefix: "h")
                    }
                    let hashtagMentionsArray = data?.valueForKeyPath(TwitterKey.Entities.Hashtags) as? NSArray
                    hashtags = getIndexedKeywords(hashtagMentionsArray, inText: text, prefix: "#")
                    let urlMentionsArray = data?.valueForKeyPath(TwitterKey.Entities.URLs) as? NSArray
                    urls = getIndexedKeywords(urlMentionsArray, inText: text, prefix: "h")
                    let userMentionsArray = data?.valueForKeyPath(TwitterKey.Entities.UserMentions) as? NSArray
                    userMentions = getIndexedKeywords(userMentionsArray, inText: text, prefix: "@")
                    return
                }
            }
        }
        self.text = ""
        self.user = User()
        self.created = NSDate()
        self.media = [MediaItem]()
        self.id = ""
        return nil
    }
    
    private func getIndexedKeywords(dictionary: NSArray?, inText: String, prefix: String? = nil) -> [IndexedKeyword] {
        var results = [IndexedKeyword]()
        if let indexedKeywords = dictionary {
            for indexedKeywordData in indexedKeywords {
                if let indexedKeyword = IndexedKeyword(data: indexedKeywordData as? NSDictionary, inText: inText, prefix: prefix) {
                    results.append(indexedKeyword)
                }
            }
        }
        return results
    }
    
    struct TwitterKey {
        static let User = "user"
        static let Text = "text"
        static let Created = "created_at"
        static let ID = "id_str"
        static let Media = "entities.media"
        struct Entities {
            static let Hashtags = "entities.hashtags"
            static let URLs = "entities.urls"
            static let UserMentions = "entities.user_mentions"
            static let Indices = "indices"
        }
        
    }
}

//NSString rangeOfString extention

private extension NSString {
    func rangeOfString(substring: NSString, nearRange:NSRange) -> NSRange {
        var start = max(min(nearRange.location, length-1), 0)
        var end = max(min(nearRange.location + nearRange.length, length), 0)
        var done = false
        while !done {
            let range = rangeOfString(substring as String, options: NSStringCompareOptions(), range: NSMakeRange(start, end-start))
            if range.location != NSNotFound {
                return range
            }
            done = true
            if start > 0 { start-- ; done = false }
            if end < length { end++; done = false }
        }
        return NSMakeRange(NSNotFound, 0)
    }
}

private extension String {
    var asTwitterDate: NSDate? {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            return dateFormatter.dateFromString(self)
        }
    }
}
