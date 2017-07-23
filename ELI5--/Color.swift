//
//  Color.swift
//  ELI5--
//
//  Created by CheckoutUser on 7/22/17.
//  Copyright © 2017 CheckoutUser. All rights reserved.
//

import UIKit

// Color cells of the root table view
func colorObject(_ category : String, _ cell : inout UIColor) {
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
