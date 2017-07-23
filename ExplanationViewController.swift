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
   
   @IBOutlet weak var firstImage: UIImageView!
   @IBOutlet weak var secondImage: UIImageView!
   @IBOutlet weak var thirdImage: UIImageView!
   
   var threadURL : String?
   var explanation : String?
   var thread : RedditThread? {
      // Property observer, execute when thread is set
      didSet {
         setText()
         if (explanation == nil) {
            getTopExplanation(threadURL!)
         }
      }
   }
   
   // Set text for the thread title and explanation
   func setText() {
      // Color the background of the
      colorObject((thread?.category)!, &self.view.backgroundColor!)
      
      if let threadTitle : String = self.thread?.title {
         print(thread?.title ?? "EMPTY")
         threadTitleLabel!.text = threadTitle
         //explanationLabel!.text = "This is some placeholder text for the explanation. I think Sacred Hearts Club is a pretty diverse album that inspires happiness." +
          //" This is some placeholder text for the explanation. I think Sacred Hearts Club is a pretty diverse album that inspires happiness."
      }
      
      if let url : String = thread?.url {
         threadURL = url + ".json"
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
            // No do-catch since no errors thrown
            jsonData = JSON(data)
            
            // TODO: Make send setThreadArray as a parameter
            print("Finding top explanation...")
            self.parseJSON(jsonData!)
         }
      }
      
      task.resume()
   }
   
   // Drill down to get the top explanation
   func parseJSON(_ json : JSON?) {
      // Index 1 contains all the comments (index contains metadata for thread
      //var score = json?[1]["data"]["children"][0]["data"]["score"].number
      explanation = json?[1]["data"]["children"][0]["data"]["body"].string!
      
      print("EXPLANATION: " + explanation!)
      
      explanationLabel!.text = explanation
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
      //self.setText()
   }
}
