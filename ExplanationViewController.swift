//
//  ExplanationViewController.swift
//  ELI5--
//
//  Created by Duc Dao on 7/22/17.
//  Copyright © 2017 Duc Dao. All rights reserved.
//

import UIKit

class ExplanationViewController: UIViewController {
   @IBOutlet weak var threadTitleLabel: UILabel!
   @IBOutlet weak var explanationLabel: UILabel!
   
   // The number of comments we want returned in the JSON
   let maxComments : Int = 5
   
   var threadURL : String?
   var threadTitle : String?
   var explanation : String?
   var thread : RedditThread? {
      // Property observer, execute when thread is set
      didSet {
         // Color the background of the
         colorObject((thread?.category)!, &self.view.backgroundColor!)
         
         getTitle()
         getURL()
         getTopExplanation(threadURL!)
         addTap(threadTitleLabel)
      }
   }
   
   // Keywords taken from the explanation
   var keyWords = [String]()
   
   // Set text for the thread title and explanation
   func getTitle() {
      if let title : String = self.thread?.title {
         print(title)
         self.threadTitle = title
      }
   }
   
   func getURL() {
      if let url : String = thread?.url {
         // Modify URL to get the JSON containing the top [maxComments] comments
         self.threadURL = url + ".json?sort=top&limit=" + String(maxComments)
      }
   }
   
   // Function that gets JSON from some API
   func getTopExplanation(_ apiString : String) {
      var jsonData : JSON?
      
      let session = URLSession(configuration: URLSessionConfiguration.default)
      let request = URLRequest(url: URL(string: apiString)!)
      let task: URLSessionDataTask = session.dataTask(with: request) {
         (receivedData, response, error) -> Void in
         if let data = receivedData {
            // Index of array where all comments live. Index 0 = thread metadata
            let commentsIndex = 1
            var index = -1
            
            // No do-catch since no errors thrown
            jsonData = JSON(data)
            
            // Go to beginning of the comments
            jsonData = jsonData?[commentsIndex]["data"]["children"]
            
            print("Finding top explanation...")
            // Find the top comment that's NOT a stickied post
            repeat {
               index = index + 1
               
               self.explanation = jsonData?[index]["data"]["body"].string!
            } while (jsonData?[index]["data"]["stickied"].bool! == true ||
               jsonData?[index]["data"]["body"].string! == "[removed]") &&
               index < self.maxComments
            
            print("EXPLANATION: " + self.explanation!)
            
            DispatchQueue.main.async {
               self.updateUI()
            }
         }
      }
      
      task.resume()
   }
   
   // Update labels in the view
   func updateUI() {
      threadTitleLabel!.text = threadTitle
      explanationLabel!.text = explanation
   }
   
   // Add ability to tap to go to reddit thread on the web
   func addTap(_ label : UILabel!) {
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.threadTitleGoToURL(_:)))
      label.isUserInteractionEnabled = true
      label.addGestureRecognizer(tap)
   }
   
   // Take user to thread on reddit in web browser
   func threadTitleGoToURL(_ sender: UITapGestureRecognizer) {
      // Do stuff
      let url = URL(string: thread!.url)
      let application = UIApplication.shared
      application.open(url!, options: [:], completionHandler: nil)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
}
