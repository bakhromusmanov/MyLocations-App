//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 04/12/24.
//

import UIKit

extension UIImage {
   func resize(withBounds bounds: CGSize) -> UIImage {
      let horizontalAspect = bounds.width / size.width
      let verticalAspect = bounds.height / size.height
      let ratio = max(horizontalAspect, verticalAspect)
      
      let newSize = CGSize(width: size.width*ratio, height: size.height*ratio)
      
      UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
      draw(in: CGRect(origin: CGPoint.zero, size: newSize))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return newImage!
   }
}
