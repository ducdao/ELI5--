//
//  MainTVController.swift
//  ELI5--
//
//  Created by Duc Dao on 7/19/17.
//  Copyright © 2017 Duc Dao. All rights reserved.
//

import UIKit

// Category colors used in ELI5 subreddit
extension UIColor {
   static var Mathematics : UIColor {
      return UIColor(red: 129, green: 199, blue: 132, alpha: 1)
   }
   static var Economics : UIColor {
      return UIColor(red: 149, green: 117, blue: 205, alpha: 1)
   }
   static var Culture : UIColor {
      return UIColor(red: 121, green: 134, blue: 203, alpha: 1)
   }
   static var Biology : UIColor {
      return UIColor(red: 77, green: 182, blue: 172, alpha: 1)
   }
   static var Chemistry : UIColor {
      return UIColor(red: 240, green: 98, blue: 146, alpha: 1)
   }
   static var Physics : UIColor {
      return UIColor(red: 79, green: 195, blue: 247, alpha: 1)
   }
   static var Technology : UIColor {
      return UIColor(red: 120, green: 144, blue: 156, alpha: 1)
   }
   static var Engineering : UIColor {
      return UIColor(red: 161, green: 136, blue: 127, alpha: 1)
   }
   static var Other : UIColor {
      return UIColor(red: 158, green: 158, blue: 158, alpha: 1)
   }
}

class MainTVController: UITableViewController {

   // Google Custom Search API information
   // cx: 000826048872980895053:0ntfgkywxg8=12xaw1
   // searchType: image
   // q : query term
   // API key: AIzaSyDpFuKuy-dt8ON1GUzvX7EXWOUTQk_8DDQ=dcazx
   // Example endpoint hit: https://www.googleapis.com/customsearch/v1?key=AIzaSyDpFuKuy-dt8ON1GUzvX7EXWOUTQk_8DDQ&cx=000826048872980895053:0ntfgkywxg8&q=starcraft2&safe=high&searchType=image
   
   var threadList = [RedditThread]()
   
   @IBOutlet weak var threadTitleLabel: UILabel!
   @IBOutlet weak var categoryLabel: UILabel!
   @IBOutlet weak var hoursSincePostLabel: UILabel!
   
   // Endpoints from Reddit, Google Custom Search
   let GETeli5 : String = "https://www.reddit.com/r/explainlikeimfive/new.json?limit=25"
   let GETImgSearch : String = "https://www.googleapis.com/customsearch/v1?" +
   "key=AIzaSyDpFuKuy-dt8ON1GUzvX7EXWOUTQk_8DDQ&" +
   "cx=000826048872980895053:0ntfgkywxg8&" +
   "q=starcraft2&safe=high&searchType=image"
   
   override func viewDidLoad() {
      super.viewDidLoad()

      self.tableView.estimatedRowHeight = 75.0
      self.tableView.rowHeight = UITableViewAutomaticDimension
      
      print("STARTING APP...")
      
      // Uncomment following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
      
      // Get information from reddit
      getJSON(GETeli5)
      
      DispatchQueue.main.async {
         self.tableView.reloadData()
      }
      
      // Google image search
      //getJSON(GETImgSearch)
   }
   
   // Function that gets JSON from some API
   func getJSON(_ apiString : String) {
      var jsonData : JSON?
      
      let session = URLSession(configuration: URLSessionConfiguration.default)
      let request = URLRequest(url: URL(string: apiString)!)
      let task: URLSessionDataTask = session.dataTask(with: request) {
         (receivedData, response, error) -> Void in
         if let data = receivedData {
            // No do-catch since no errors thrown
            jsonData = JSON(data)
            
            // TODO: Make send setThreadArray as a parameter
            print("Initializing array of threads")
            self.setThreadList(jsonData!)
         }
      }
      
      task.resume()
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   // Return the number of rows
      return threadList.count
   }

   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for:indexPath) as! ThreadTVCell
      
      // Configure the cell
      let thisThread = threadList[indexPath.row]
      
      cell.threadTitleLabel!.text = thisThread.title
      cell.categoryLabel!.text = thisThread.category
      cell.hoursSincePostLabel!.text = String(describing: thisThread.createdInEpoch)
      
      //cell.threadTitleLabel?.text = "THREAD TITLE"
      //cell.categoryLabel?.text = "CATEGORY HERE"
      //cell.hoursSincePostLabel?.text = "HOURS HERE"
      
      return cell
   }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little 
    // preparation before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   
   // Extracts relevant information from a JSON
   func setThreadList(_ json : JSON) {
      // Get to array of important information in the JSON
      let childrenJSON : JSON = json["data"]["children"]
      
      for (_, value):(String, JSON) in childrenJSON {
         var data : JSON = value["data"]
         
         let title = data["title"].string!
         let category : String = data["link_flair_text"].string ?? "Other"
         let createdInEpoch = data["created"].number!
         let url = data["url"].string!
         
         // Debugging print statements
         print("TITLE: " + title)
         print("CATEGORY: " + category)
         print("CREATED: " + String(describing: createdInEpoch))
         print("URL: " + url)
         print()
         
         // Save information extracted from JSON
         self.threadList.append(RedditThread(title: title,
                                         category: category,
                                         createdInEpoch: createdInEpoch,
                                         url: url))
      }
      
      print(threadList.count)
      
      return
   }
}
