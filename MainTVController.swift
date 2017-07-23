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
      return UIColor(red: 129/255, green: 199/255, blue: 132/255, alpha: 1.0)
   }
   static var Economics : UIColor {
      return UIColor(red: 149/255, green: 117/255, blue: 205/255, alpha: 1.0)
   }
   static var Culture : UIColor {
      return UIColor(red: 121/255, green: 134/255, blue: 203/255, alpha: 1.0)
   }
   static var Biology : UIColor {
      return UIColor(red: 77/255, green: 182/255, blue: 172/255, alpha: 1.0)
   }
   static var Chemistry : UIColor {
      return UIColor(red: 240/255, green: 98/255, blue: 146/255, alpha: 1.0)
   }
   static var Physics : UIColor {
      return UIColor(red: 79/255, green: 195/255, blue: 247/255, alpha: 1.0)
   }
   static var Technology : UIColor {
      return UIColor(red: 120/255, green: 144/255, blue: 156/255, alpha: 1.0)
   }
   static var Engineering : UIColor {
      return UIColor(red: 161/255, green: 136/255, blue: 127/255, alpha: 1.0)
   }
   static var Other : UIColor {
      return UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0)
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
   
   // Endpoints from Reddit, Google Custom Search
   let GETeli5 : String = "https://www.reddit.com/r/explainlikeimfive/.json"
   let GETImgSearch : String = "https://www.googleapis.com/customsearch/v1?" +
   "key=AIzaSyDpFuKuy-dt8ON1GUzvX7EXWOUTQk_8DDQ&" +
   "cx=000826048872980895053:0ntfgkywxg8&" +
   "q=starcraft2&safe=high&searchType=image"
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      print("STARTING APP...")
      
      refreshControl = UIRefreshControl()
      refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
      refreshControl?.addTarget(self, action: Selector("refresh:"), for: UIControlEvents.valueChanged)
      
      // Get information from reddit
      getJSON(GETeli5)
      
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

   override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      cell.backgroundColor = UIColor.clear
   }

   func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return 100
   }
   
   func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
   }
   
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
      
      cell.contentView.backgroundColor = .clear
      
      // Color the cell with its respective category
      colorCell(thisThread.category, &(cell.contentView.backgroundColor!))
      /*
      switch(thisThread.category) {
      case "Mathematics":
         cell.contentView.backgroundColor = .Mathematics
      case "Economics":
         cell.contentView.backgroundColor = .Economics
      case "Culture":
         cell.contentView.backgroundColor = .Culture
      case "Biology":
         cell.contentView.backgroundColor = .Biology
      case "Chemistry":
         cell.contentView.backgroundColor = .Chemistry
      case "Physics":
         cell.contentView.backgroundColor = .Physics
      case "Technology":
         cell.contentView.backgroundColor = .Technology
      case "Engineering":
         cell.contentView.backgroundColor = .Engineering
      default:
         cell.contentView.backgroundColor = .Other
      }*/
      
      cell.threadTitleLabel!.text = thisThread.title
      cell.categoryLabel!.text = thisThread.category
      cell.hoursSincePostLabel!.text = formatDate(thisThread.createdInEpoch)
      
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
         let createdInEpoch = data["created"].double!
         let url = data["url"].string!
         
         // Debugging print statements
         print("TITLE: " + title)
         print("CATEGORY: " + category)
         print("CREATED: " + String(describing: createdInEpoch))
         print("URL: " + url)
         print()
         
         // Save information extracted from JSON
         threadList.append(RedditThread(title: title,
                                         category: category,
                                         createdInEpoch: createdInEpoch,
                                         url: url))
      }
      
      DispatchQueue.main.async {
         self.tableView.reloadData()
         self.refreshControl?.endRefreshing()
      }
      
      print(threadList.count)
   }
   
   func colorCell(_ category : String, _ cell : inout UIColor) {
      switch(category) {
         case "Mathematics":
            cell = UIColor.Mathematics
         case "Economics":
            cell = UIColor.Economics
         case "Culture":
            cell = UIColor.Culture
         case "Biology":
            cell = UIColor.Biology
         case "Chemistry":
            cell = UIColor.Chemistry
         case "Physics":
            cell = UIColor.Physics
         case "Technology":
            cell = UIColor.Technology
         case "Engineering":
            cell = UIColor.Engineering
         default:
            cell = UIColor.Other
      }
   }
   
   // Formats dates from double to string
   func formatDate(_ time : Double) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "h:mm a MMMM dd, yyyy"
      
      return formatter.string(from: Date(timeIntervalSince1970: time))
   }
   
   func refresh(sender:AnyObject) {
      getJSON(GETeli5)
   }
}
