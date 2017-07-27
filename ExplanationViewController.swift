//
//  ExplanationViewController.swift
//  ELI5--
//  Demo Version
//
//  Created by Duc Dao on 7/22/17.
//  Copyright © 2017 Duc Dao. All rights reserved.
//

import UIKit

class ExplanationViewController: UIViewController {
   @IBOutlet weak var threadTitleLabel: UILabel!
   @IBOutlet weak var firstExplanationLabel: UILabel!
   @IBOutlet weak var secondExplanationLabel: UILabel!
   
   @IBOutlet weak var firstImage: UIImageView!
   @IBOutlet weak var secondImage: UIImageView!
   @IBOutlet weak var thirdImage: UIImageView!
   
   @IBOutlet weak var scrollView: UIScrollView!
   
   // The number of comments we want returned in the JSON
   let maxComments : Int = 4
   
   // 2 sentences extracted from the full explanation
   var firstExplanation : String?
   var secondExplanation : String?
   var fullExplanation : String?
   
   var threadURL : String?
   var threadTitle : String?
   var threadJSON : JSON?
   var thread : RedditThread? {
      // Property observer, execute when thread is set
      didSet {
         // Color the background of the cell
         colorObject((thread?.category)!, &self.view.backgroundColor!)
         
         getTitle()
         getURL()
         
         // Get JSON pertaining to the thread
         getJSON("GET", Data(), threadURL!) { jsonData in
            self.getTopExplanation(jsonData)
            self.getKeyExplanations()
            self.getSearchTerms()
         }
         
         addTapToWeb(threadTitleLabel)
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
   
   func getJSON(_ httpMethod : String, _ httpBody : Data, _ endpoint : String, completion: @escaping (JSON) -> Void) {
      var jsonData : JSON?
      
      var request = URLRequest(url: URL(string: endpoint)!)
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = httpMethod
      
      // Only populate body if it's a POST method
      if (request.httpMethod == "POST") {
         request.httpBody = httpBody
      }
      
      let session = URLSession(configuration: URLSessionConfiguration.default)
      let task: URLSessionDataTask = session.dataTask(with: request) {
         (receivedData, response, error) -> Void in
         if let data = receivedData {
            // Check for HTTP errors
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
               print("statusCode should be 200, but is \(httpStatus.statusCode)")
               print("response = \(String(describing: response))")
            }
            
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
      // Remove newlines and replace &amp; with &
      threadTitle = threadTitle?.trimmingCharacters(in: .newlines).replacingOccurrences(of: "&amp;", with: "&")
      
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
   
   // Get the string for some endpoint
   func getLangHTTPMethodString(_ apiMethod : String) -> String {
      let apiKey = "AIzaSyCCQtZQUSw85jaY-BN1_tFnZOnZf2P-dpw"
      
      return "https://language.googleapis.com/v1/documents:" + apiMethod + "?key=" + apiKey
   }
   
   // Extract keywords from thread explanation
   func getKeyExplanations() {
      print("EXTRACTING KEYWORDS FROM THREAD EXPLANATION...")
      
      let requestBodyJSON = createDocumentJSON(fullExplanation!)
      let jsonData = try? JSONSerialization.data(withJSONObject: requestBodyJSON, options: .prettyPrinted)
      
      getJSON("POST", jsonData!, getLangHTTPMethodString("analyzeSentiment")) { responseJSON in
         // Remove newlines and replace &amp; with &
         self.fullExplanation = self.fullExplanation?.trimmingCharacters(in: .newlines).replacingOccurrences(of: "&amp;", with: "&")
         
         // Set first and second explanation that will be displayed on explanation view
         self.parseAnalyzeSentimentJSON(responseJSON)
      }
   }
   
   // Extract key words from the first/secondExplanation and get 3 search terms
   func getSearchTerms() {
      print("\nEXTRACTING 3 KEY TERMS FOR IMAGE SEARCH...")
      
      let requestBodyJSON = createDocumentJSON(fullExplanation!)
      let jsonData = try? JSONSerialization.data(withJSONObject: requestBodyJSON, options: .prettyPrinted)
      
      getJSON("POST", jsonData!, getLangHTTPMethodString("analyzeEntities")) { responseJSON in
         print(responseJSON)
         self.parseAnalyzeEntitiesResponseJSON(responseJSON)
      }
   }
   
   // Create a new documents JSON specified by Google here: 
   // https://cloud.google.com/natural-language/docs/reference/rest/v1beta2/documents#Document
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
      
      // Have all text values for text elements, update all text UI on main thread
      DispatchQueue.main.async {
         self.updateUI()
         /*self.scrollView.addSubview(self.threadTitleLabel)
         self.scrollView.addSubview(self.firstExplanationLabel)
         self.scrollView.addSubview(self.secondExplanationLabel)
         
         self.view.addSubview(self.scrollView)*/
      }
   }
   
   // Parse the JSON received from the POST to analyzeEntities
   func parseAnalyzeEntitiesResponseJSON(_ json : JSON) {
      var keyWordsSet = Set<String>()
      let entities = json["entities"]
      
      // Get all proper nouns
      for index in 0..<entities.count {
         let word = entities[index]["mentions"][0]["text"]["content"].string!
         let mentionType = entities[index]["mentions"][0]["type"].string!
         let type = entities[index]["type"].string!
         
         if mentionType == "PROPER" || mentionType == "COMMON" && type != "OTHER" {
            print(word + " " + mentionType)
            
            // Add words if it's not a link
            if canOpenAsURL(word) == false {
               keyWordsSet.insert(word)
            }
         }
      }
      
      self.keyWords = Array(keyWordsSet)
      print("\nPRINTING KEYWORDS..." + String(describing: keyWordsSet))
      
      print("COUNT: " + String(describing: keyWords))
      
      // Set 3 images in explanation view relating to thread
      self.getImageLink(self.keyWords[getRand(keyWords.count)], self.firstImage)
      self.getImageLink(self.keyWords[getRand(keyWords.count)], self.secondImage)
      self.getImageLink(self.keyWords[getRand(keyWords.count)], self.thirdImage)
   }
   
   func getRand(_ seed : Int) -> Int {
      return Int(arc4random_uniform((UInt32(seed))))
   }
   
   func canOpenAsURL(_ urlString: String?) -> Bool {
      if let urlString = urlString {
         if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
         }
      }
      
      return false
   }
   
   // Do an image search on Google
   func getImageLink(_ searchTerm : String, _ imageView : UIImageView) {
      var searchTerm = searchTerm.trimmingCharacters(in: .whitespaces)
      searchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
      
      let endpoint : String = "https://www.googleapis.com/customsearch/v1?q=" + searchTerm + "&imgSize=medium&imgType=photo" +
         "&cx=000826048872980895053%3A0ntfgkywxg8&num=5&safe=high&searchType=" +
         "image&siteSearch=google.com/&key=AIzaSyCCQtZQUSw85jaY-BN1_tFnZOnZf2P-dpw"
      
      getJSON("GET", Data(), endpoint) { responseJSON in
         print(responseJSON)
         
         let itemsJSON : JSON = responseJSON["items"]
         
         print("LINK: " + String(describing: itemsJSON[self.getRand(itemsJSON.count)]["link"]))
         
         self.setImageView(String(describing: itemsJSON[self.getRand(itemsJSON.count)]["link"]), imageView)
      }
   }
   
   func setImageView(_ link : String, _ imageView : UIImageView) {
      //let link = link.replacingOccurrences(of: "http:", with: "https:")
      
      let request = URLRequest(url: URL(string: link)!)
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
         if error != nil {
            print(error!)
            return
         }
         
         DispatchQueue.main.async {
            imageView.image = UIImage(data: data!)
         }
      }
      
      task.resume()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      scrollView = UIScrollView(frame: view.bounds)
      //scrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
   }
}
