//
//  String+AddText.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 04/12/24.
//

extension String {
   mutating func add(text: String?, separatedBy separator: String = ""){
      if let text = text {
         self += text
         self += separator
      }
   }
}
