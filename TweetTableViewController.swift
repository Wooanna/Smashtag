//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Yoanna Mareva on 4/22/16.
//  Copyright © 2016 Yoanna Mareva. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    var searchText : String? = "Telerik" {
        didSet {
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    //MARK: ViewControllerLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }

    func refresh() {
        if searchText != nil {
            let request = TwitterRequest(search: searchText!, count: 100)
            request.fetchTweets { (newTweets) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if newTweets.count > 0 {
                        self.tweets.insert(newTweets, atIndex: 0)
                        self.tableView.reloadData()
                    }
                    
                })
            }
        }

    }
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        
        //cell configuration
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

}
