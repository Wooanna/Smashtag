//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Yoanna Mareva on 4/22/16.
//  Copyright © 2016 Yoanna Mareva. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    
    @IBOutlet weak var tweetCreated: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    func updateUI() {
        tweetText?.text = nil
        userName?.text = nil
        profileImage?.image = nil
        
        if let tweet = self.tweet {
            textLabel?.text = tweet.text
            if textLabel?.text != nil {
                for _ in tweet.media {
                    textLabel!.text! += "imageIcon"
                }
            }
            userName?.text = "\(tweet.user)" //tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                
                    //mainThread
                    let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                    dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
                        if let imageData = NSData(contentsOfURL: profileImageURL) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                 self.profileImage?.image = UIImage(data: imageData)
                            })
                        }
                    })
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            
            tweetCreated?.text = formatter.stringFromDate(tweet.created)
        }
    }
}
