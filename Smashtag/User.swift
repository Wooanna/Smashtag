//
//  User.swift
//  Smashtag
//
//  Created by Yoanna Mareva on 4/22/16.
//  Copyright © 2016 Yoanna Mareva. All rights reserved.
//

import Foundation

public class User : CustomStringConvertible
{
    public var screenName: String
    public var name: String
    public var profileImageURL: NSURL?
    public var verified: Bool = false
    public var id: String!
    
    public var description: String {
        let v = verified ? " check" : " "
        return "@\(screenName) (\(name))\(v)"
    }
    
    // MARK: Private Implementation
    
    init?(data: NSDictionary?) {
        let name = data?.valueForKeyPath(TwitterKey.Name) as? String
        let screenName = data?.valueForKeyPath(TwitterKey.ScreenName) as? String
        if name != nil && screenName != nil {
            self.name = name!
            self.screenName = screenName!
            self.id = data?.valueForKeyPath(TwitterKey.ID) as? String
            if let verified = data?.valueForKeyPath(TwitterKey.Verified)?.boolValue {
                self.verified = verified
            }
            if let urlString = data?.valueForKeyPath(TwitterKey.ProfileImageURL) as? String {
                self.profileImageURL = NSURL(string: urlString)
            }
        } else {
            self.name = ""
            self.screenName = ""
            return nil
        }
        
    }
    
    var asPropertyList: AnyObject {
        var dictionary = Dictionary<String, String>()
        dictionary[TwitterKey.Name] = self.name
        dictionary[TwitterKey.ScreenName] = self.screenName
        dictionary[TwitterKey.ID] = self.id
        dictionary[TwitterKey.ProfileImageURL] = self.profileImageURL?.absoluteString
        dictionary[TwitterKey.Verified] = self.verified ? "YES" : "NO"
        return dictionary
    }
    
    init() {
        screenName = "Unknown"
        name = "Unknown"
    }
    
    struct TwitterKey {
        static let Name = "name"
        static let ScreenName = "screen_name"
        static let ID = "id_str"
        static let Verified = "verified"
        static let ProfileImageURL = "profile_image_url"
    }
    
}