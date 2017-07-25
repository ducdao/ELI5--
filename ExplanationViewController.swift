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
   @IBOutlet weak var firstExplanationLabel: UILabel!
   @IBOutlet weak var secondExplanationLabel: UILabel!
   
   // The number of comments we want returned in the JSON
   let maxComments : Int = 5
   
   var threadURL : String?
   var threadTitle : String?
   var threadJSON : JSON?
   var thread : RedditThread? {
      // Property observer, execute when thread is set
      didSet {
         // Color the background of the
         colorObject((thread?.category)!, &self.view.backgroundColor!)
         
         getTitle()
         getURL()
         
         // Get JSON pertaining to the thread
         getJSON("GET", threadURL!) { jsonData in
            self.getTopExplanation(jsonData)
            self.getKeyWords()
         }
         
         addTapToWeb(threadTitleLabel)
      }
   }
   
   // Keywords taken from the explanation
   var keyWords = Set<String>()
   
   // 2 sentences extracted from the full explanation
   var firstExplanation : String?
   var secondExplanation : String?
   var fullExplanation : String?
   
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
   
   func getJSON(_ httpMethod : String, _ endpoint : String, completion: @escaping (JSON) -> Void) {
      var jsonData : JSON?
      
      var request = URLRequest(url: URL(string: endpoint)!)
      request.httpMethod = httpMethod
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      
      let session = URLSession(configuration: URLSessionConfiguration.default)
      let task: URLSessionDataTask = session.dataTask(with: request) {
         (receivedData, response, error) -> Void in
         if let data = receivedData {
            jsonData = JSON(data)
            
            completion(jsonData!)
         }
      }
      
      task.resume()
   }
   
   // Function that gets JSON from some API
   func getTopExplanation(_ json : JSON) {
      let comments : JSON
      
      // Index of the comments of interest, index 0 contains metadata for thread
      let commentsIndex = 1
      var index = -1
      
      comments = json[commentsIndex]["data"]["children"]
            
      print("Finding top explanation...")
      // Find the top comment that's NOT a stickied post
      repeat {
         index = index + 1
         
         self.fullExplanation = comments[index]["data"]["body"].string!
      } while (comments[index]["data"]["stickied"].bool! == true ||
         comments[index]["data"]["body"].string! == "[removed]") &&
         index < self.maxComments
            
      print("EXPLANATION: " + self.fullExplanation!)
   }
   
   // Update labels in the view
   func updateUI() {
      threadTitleLabel!.text = threadTitle
      firstExplanationLabel!.text = firstExplanation
      secondExplanationLabel!.text = secondExplanation
   }
   
   // Add ability to tap to go to reddit thread on the web
   func addTapToWeb(_ label : UILabel!) {
      let tap = UITapGestureRecognizer(target: self,
         action: #selector(self.threadTitleGoToURL(_:)))
      label.isUserInteractionEnabled = true
      label.addGestureRecognizer(tap)
   }
   
   // Take user to thread on reddit in web browser
   func threadTitleGoToURL(_ sender: UITapGestureRecognizer) {
      let url = URL(string: thread!.url + "?sort=top")
      let application = UIApplication.shared
      application.open(url!, options: [:], completionHandler: nil)
   }
   
   // Get the string for the endpoint of analyzeSentiment method
   func getAnalyzeSentimentStrng() -> String {
      let apiMethod = "analyzeSentiment"
      let apiKey = "AIzaSyBVsj-vlGYJsPfmYM_NqMwBgsv4jUoSmQw"
      
      return "https://language.googleapis.com/v1/documents:" + apiMethod + "?key=" + apiKey
   }
   
   // Extract keywords from thread explanation
   func getKeyWords() {
      print("EXTRACTING KEYWORDS FROM THREAD EXPLANATION...")
      
      var request = URLRequest(url: URL(string: getAnalyzeSentimentStrng())!)
      request.httpMethod = "POST"
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      
      let requestBodyJSON = createDocumentJSON(fullExplanation!)
      let jsonData = try? JSONSerialization.data(withJSONObject: requestBodyJSON, options: .prettyPrinted)
      
      request.httpBody = jsonData
      let task = URLSession.shared.dataTask(with: request) {
         data, response, error in
         // Check for fundamental networking error
         guard let data = data, error == nil else {
            print("error=\(String(describing: error))")
            return
         }
         
         // Check for HTTP errors
         if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(String(describing: response))")
         }
         
         let responseJSON = JSON(data)
         
         print("responseString = " + String(describing: responseJSON))
         
         self.fullExplanation = self.fullExplanation?.trimmingCharacters(in: .newlines)
         self.fullExplanation = self.fullExplanation?.replacingOccurrences(of: "&amp;", with: "&")
         
         // Set first and second explanation that will be displayed on explanation view
         self.parseAnalyzeSentimentJSON(responseJSON)
         
         DispatchQueue.main.async {
            self.updateUI()
         }
         
         //self.getSearchTerms()
      }
      
      task.resume()
   }
   
   func getSearchTerms() {
      print("EXTRACTING SEARCH TERMS IMAGE SEARCH...")
      let apiMethod = "analyzeEntities"
      let apiKey = "AIzaSyBVsj-vlGYJsPfmYM_NqMwBgsv4jUoSmQw"
      let langURLString = "https://language.googleapis.com/v1/documents:" +
         apiMethod + "?key=" + apiKey
      
      var request = URLRequest(url: URL(string: langURLString)!)
      request.httpMethod = "POST"
      //request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      
      let requestBodyJSON = createDocumentJSON(fullExplanation!)
      let jsonData = try? JSONSerialization.data(withJSONObject: requestBodyJSON, options: .prettyPrinted)
      
      request.httpBody = jsonData
      let task = URLSession.shared.dataTask(with: request) {
         data, response, error in
         // Check for fundamental networking error
         guard let data = data, error == nil else {
            print("error=\(String(describing: error))")
            return
         }
         
         // Check for HTTP errors
         if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(String(describing: response))")
         }
         
         let responseJSON = JSON(data)
         
         print("responseString = " + String(describing: responseJSON))
         
         self.fullExplanation = self.fullExplanation?.trimmingCharacters(in: .newlines)
         self.fullExplanation = self.fullExplanation?.replacingOccurrences(of: "&amp;", with: "&")
         
         // Get keywords for image search
         self.parseAnalyzeEntitiesResponseJSON(responseJSON)
      }
      
      task.resume()
   }
   
   // Create a new documents JSON specified by Google here: https://cloud.google.com/natural-language/docs/reference/rest/v1beta2/documents#Document
   func createDocumentJSON(_ content : String) -> [String:AnyObject] {
      let contentJSON : [String:AnyObject] =
         ["content" : String(describing: content) as AnyObject,
          "type" : "PLAIN_TEXT" as AnyObject]
      let documentJSON : [String:AnyObject] =
         ["document" : contentJSON as AnyObject]
      
      return documentJSON
   }
   
   // Parse the JSON received from the POST to analyzeSentiment
   func parseAnalyzeSentimentJSON(_ json : JSON) {
      var max : Double = -1, min : Double = 1
      
      let sentences = json["sentences"]
      
      // Find the top 2 sentences in the explanations
      for index in 0..<sentences.count {
         let answer = sentences[index]["text"]["content"].string!
         let score = sentences[index]["sentiment"]["score"].double!
         
         print("ANSWER: " + answer)
         print("SCORE: " + String(score))
         
         if max < score {
            max = score
            firstExplanation = answer
         }
         
         if score < min {
            min = score
            secondExplanation = answer
         }
      }
      
      print("MAX ANSWER: " + firstExplanation!)
      print("   MIN ANSWER: " + secondExplanation!)
      
      // Update UI on the main thread asynchronously
      DispatchQueue.main.async {
         self.updateUI()
      }
   }
   
   // Parse the JSON received from the POST to analyzeEntities
   func parseAnalyzeEntitiesResponseJSON(_ json : JSON) {
      let entities = json["entities"]

      for index in 0..<entities.count {
         let word = entities[index]["mentions"][0]["text"]["content"].string!
         let mentionType = entities[index]["mentions"][0]["type"].string!
         let type = entities[index]["type"].string!
         
         if mentionType == "PROPER" || mentionType == "COMMON" && type != "OTHER" {
            print(word + " " + mentionType)
            
            keyWords.insert(word)
         }
      }
      
      print(keyWords)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
}
