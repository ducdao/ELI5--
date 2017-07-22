//
//  MainTVController.swift
//  ELI5--
//
//  Created by Duc Dao on 7/19/17.
//  Copyright © 2017 Duc Dao. All rights reserved.
//

import UIKit

class MainTVController: UITableViewController {

   // Information used to populate cells in the MainTVController
   struct ThreadFields {
      var title : String
      var category : String
      var createdInEpoch : NSNumber
      var url : String
   }
   
   enum Category : String {
      case
      Bio   = "Biology",
      Chem  = "Chemistry",
      Cult  = "Culture",
      Econ  = "Economics",
      Eng   = "Engineering",
      Math  = "Mathematics",
      Other = "Other",
      Phys  = "Physics",
      Tech  = "Technology"
   }
   
   var threadArray : [ThreadFields] = []
   
   @IBOutlet weak var threadTitleLabel: UILabel!
   @IBOutlet weak var categoryLabel: UILabel!
   @IBOutlet weak var hoursSincePostLabel: UILabel!
   
   // JSON from reddit.com/r/explainlikeimfive
   let GETeli5 : String = "https://www.reddit.com/r/explainlikeimfive/new.json?limit=25"
   
   override func viewDidLoad() {
      super.viewDidLoad()

      print("STARTING APP!")
      
      // Uncomment following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
    
      var swifty : JSON?
    
      let session = URLSession(configuration: URLSessionConfiguration.default)
      let request = URLRequest(url: URL(string: GETeli5)!)
      let task: URLSessionDataTask = session.dataTask(with: request) {
         (receivedData, response, error) -> Void in
      if let data = receivedData {
      // No do-catch since no errors thrown
            swifty = JSON(data)
         
            print("Initializing array of threads")
            self.setThreadArray(swifty!)
         }
      }
      
      task.resume()
      
      tableView.estimatedRowHeight = 75.0
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.reloadData()
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
      //return threadArray.count
      return 25
   }

   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! ThreadTVCell

      // Configure the cell
      //let thisThread = threadArray[indexPath.row]
      //cell.threadTitleLabel?.text = thisThread.title
      //cell.categoryLabel?.text = thisThread.category
      //cell.hoursSincePostLabel?.text = String(describing: thisThread.createdInEpoch)
      //cell.urlText?.text = thisThread.url
      
      cell.threadTitleLabel?.text = "THREAD TITLE"
      cell.categoryLabel?.text = "CATEGORY HERE"
      cell.hoursSincePostLabel?.text = "HOURS HERE"
      
      return cell
   }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   
   // Extracts relevant information from a JSON
   func setThreadArray(_ json : JSON) {
      // Get to array of important information in the JSON
      let childrenJSON : JSON = json["data"]["children"]
      
      for (_, value):(String, JSON) in childrenJSON {
         var data : JSON = value["data"]
         
         let title = data["title"].string!
         //let category = data["link_flair_text"].string!
         let createdInEpoch = data["created"].number!
         let url = data["url"].string!
         
         // Debugging print statements
         print("TITLE: " + title)
         print("CATEGORY: ")
         print("CREATED: " + String(describing: createdInEpoch))
         print("URL: " + url)
         
         // Save information extracted from JSON
         self.threadArray.append(ThreadFields(title: title,
                                         category: "CATEGORY",
                                         createdInEpoch: createdInEpoch,
                                         url: url))
      }
      
      print(threadArray.count)
   }
}
