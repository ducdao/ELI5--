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
      enum category {
         case bio   = "Biology"
         case chem  = "Chemistry"
         case cult  = "Culture"
         case econ  = "Economics"
         case eng   = "Engineering"
         case math  = "Mathematics"
         case other = "Other"
         case phys  = "Physics"
         case tech  = "Technology"
      }
      var timeInEpoch : Double
   }
   
   var threadArray : [ThreadFields]
   
   @IBOutlet weak var threadTitleLabel: UILabel!
   @IBOutlet weak var categoryLabel: UILabel!
   @IBOutlet weak var hoursSincePostLabel: UILabel!
   
   // JSON from reddit.com/r/explainlikeimfive
   let GETeli5 : String = "https://www.reddit.com/r/explainlikeimfive/.json"
   
   override func viewDidLoad() {
      super.viewDidLoad()

      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
    
      var swifty : JSON?
    
      let session = URLSession(configuration: URLSessionConfiguration.default)
      let request = URLRequest(url: URL(string: GETeli5)!)
      let task: URLSessionDataTask = session.dataTask(with: request) { (receivedData, response, error) -> Void in
      if let data = receivedData {
      // No do-catch since no errors thrown
            swifty = JSON(data)
         }
      }
    
      task.resume()
      
      setThreadArray(swifty)
      
      DispatchQueue.main.async {
         tableView.estimatedRowHeight = 50.0
         tableView.rowHeight = UITableViewAutomaticDimension
         tableView.reloadData()
      }
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
        return threadArray.count
    }

   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for:indexPath) as! ThreadTVCell

      // Configure the cell...
      let thisThread = threadArray[indexPath.row]
      cell.threadTitleLabel?.text = thisThread.title
      cell.categoryLabel?.text = thisThread.category
      cell.hoursSincePostLabel?.text = thisThread.timeInEpoch
      
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
   func setThreadArray(json : JSON) {
      var childrenJSON : [String:AnyObject]
      
      // Get to array of important information in the JSON
      childrenJSON = json["data"]["children"]
      
      for child in childrenJSON {
         child = child["data"]
         
         var title : String = child["title"]
         var category : ThreadFields.category = child["link_flair_text"]
         var createdInEpoch : Double = child["created"]
         
         print(str)
         print(category)
         print(createdInEpoch)
         
         // Save information extracted from JSON
         threadArray.append(ThreadFields(title, category, createdInEpoch))
      }
   }
}
